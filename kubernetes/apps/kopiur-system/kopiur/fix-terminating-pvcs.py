#!/usr/bin/env python3
"""Fix PVCs stuck in Terminating state during volsync->kopiur migration.

For each app: scale down -> remove finalizer -> wait for PVC delete ->
trigger Flux reconcile -> wait for new PVC -> scale up -> verify.

Logs to both stdout and ./fix-terminating-pvcs.log (same directory as script).

Usage:
    python3 fix-terminating-pvcs.py
"""

import json
import logging
import os
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

LOG_FILE = Path(__file__).parent / "fix-terminating-pvcs.log"

# Setup logging to both file and stdout
logger = logging.getLogger("pvc-fix")
logger.setLevel(logging.DEBUG)

fh = logging.FileHandler(LOG_FILE, mode="w")
fh.setLevel(logging.DEBUG)
fh.setFormatter(logging.Formatter("%(asctime)s %(levelname)-5s %(message)s"))

sh = logging.StreamHandler(sys.stdout)
sh.setLevel(logging.INFO)
sh.setFormatter(logging.Formatter("%(asctime)s %(levelname)-5s %(message)s"))

logger.addHandler(fh)
logger.addHandler(sh)

# Map PVC names that differ from deployment/app names
PVC_TO_APP = {
    "forgejo-data": "forgejo",
    "pgadmin-v2": "pgadmin",
    "actual-data": "actual",
    "kitchenowl-data": "kitchenowl",
    "radicale-data-v2": "radicale",
    "plex-data": "plex",
    "jellyfin-v2": "jellyfin",
}


def run(cmd, timeout=30):
    """Run a command and return (returncode, stdout, stderr)."""
    try:
        r = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=timeout)
        return r.returncode, r.stdout.strip(), r.stderr.strip()
    except subprocess.TimeoutExpired:
        return 1, "", "TIMEOUT"


def kubectl_json(cmd):
    """Run kubectl and parse JSON."""
    rc, out, err = run(cmd)
    if rc != 0 or not out:
        return None
    return json.loads(out)


def get_terminating_pvcs():
    """Get all PVCs with deletionTimestamp set."""
    data = kubectl_json("kubectl get pvc -A -o json")
    if not data:
        return []
    results = []
    for item in data.get("items", []):
        if item["metadata"].get("deletionTimestamp"):
            results.append((item["metadata"]["namespace"], item["metadata"]["name"]))
    return sorted(results)


def find_deployment(ns, pvc_name):
    """Find the deployment that mounts this PVC."""
    app_name = PVC_TO_APP.get(pvc_name, pvc_name)

    # Method 1: Find pods mounting this PVC and trace to deployment
    data = kubectl_json(f"kubectl get pods -n {ns} -o json")
    if data:
        for pod in data.get("items", []):
            volumes = pod.get("spec", {}).get("volumes", [])
            for vol in volumes:
                claim = vol.get("persistentVolumeClaim", {})
                if claim.get("claimName") == pvc_name:
                    owners = pod.get("metadata", {}).get("ownerReferences", [])
                    if owners and owners[0].get("kind") == "ReplicaSet":
                        rs_name = owners[0]["name"]
                        # Strip the trailing pod-template-hash from ReplicaSet name
                        parts = rs_name.rsplit("-", 1)
                        if len(parts) == 2:
                            return parts[0], app_name

    # Method 2: Try deployment by app name directly
    rc, out, _ = run(f"kubectl get deploy -n {ns} {app_name} --no-headers 2>/dev/null")
    if rc == 0 and out:
        return app_name, app_name

    # Method 3: Try label selector
    rc, out, _ = run(
        f"kubectl get deploy -n {ns} -l app.kubernetes.io/name={app_name} --no-headers 2>/dev/null"
    )
    if rc == 0 and out:
        return out.split()[0], app_name

    return None, app_name


def wait_for_pods_gone(ns, app_name, timeout=60):
    """Wait for pods to terminate, checking every 10s. Returns True if all gone."""
    deadline = time.time() + timeout
    while time.time() < deadline:
        rc, out, _ = run(
            f"kubectl get pods -n {ns} -l app.kubernetes.io/name={app_name} --no-headers 2>/dev/null"
        )
        active = [
            line
            for line in out.splitlines()
            if line
            and "Completed" not in line
            and "Succeeded" not in line
            and "Terminating" not in line
        ]
        if not active:
            return True
        logger.debug(f"  Still {len(active)} active pod(s), waiting...")
        time.sleep(10)
    return False


def wait_for_pvc_gone(ns, pvc_name, timeout=20):
    """Wait for PVC to be fully deleted."""
    deadline = time.time() + timeout
    while time.time() < deadline:
        rc, _, _ = run(f"kubectl get pvc {pvc_name} -n {ns} 2>/dev/null")
        if rc != 0:
            return True
        time.sleep(10)
    return False


def wait_for_pvc_bound(ns, pvc_name, timeout=30):
    """Wait for new PVC to appear and become Bound."""
    deadline = time.time() + timeout
    while time.time() < deadline:
        rc, phase, _ = run(
            f"kubectl get pvc {pvc_name} -n {ns} -o jsonpath='{{.status.phase}}' 2>/dev/null"
        )
        if phase == "Bound":
            return "Bound"
        logger.debug(f"  PVC phase: {phase or 'NotFound'}")
        time.sleep(10)
    _, phase, _ = run(
        f"kubectl get pvc {pvc_name} -n {ns} -o jsonpath='{{.status.phase}}' 2>/dev/null"
    )
    return phase or "Missing"


def get_pod_status(ns, app_name):
    """Get status of first pod for this app."""
    rc, out, _ = run(
        f"kubectl get pods -n {ns} -l app.kubernetes.io/name={app_name} --no-headers 2>/dev/null"
    )
    if out:
        parts = out.splitlines()[0].split()
        if len(parts) >= 3:
            return f"{parts[1]} {parts[2]}"  # READY STATUS
    return "NoPod"


def process_pvc(ns, pvc_name, idx, total):
    """Process a single PVC: scale down, fix, scale up. Returns (success, message)."""
    logger.info(f"[{idx}/{total}] Processing {ns}/{pvc_name}")

    deploy, app_name = find_deployment(ns, pvc_name)
    if not deploy:
        msg = f"No deployment found for {ns}/{pvc_name}"
        logger.error(f"  {msg}")
        return False, msg

    logger.info(f"  deploy={deploy} app_label={app_name}")

    # Scale down
    logger.info(f"  Scaling down {deploy}...")
    rc, _, err = run(f"kubectl scale deploy {deploy} -n {ns} --replicas=0")
    if rc != 0:
        msg = f"Failed to scale down: {err}"
        logger.error(f"  {msg}")
        return False, msg

    # Wait for pods gone
    logger.info(f"  Waiting for pods to stop...")
    if not wait_for_pods_gone(ns, app_name, timeout=60):
        logger.warning(f"  Pods still present after 60s, proceeding anyway")

    # Remove finalizer
    logger.info(f"  Removing pvc-protection finalizer...")
    run(
        f"kubectl patch pvc {pvc_name} -n {ns} "
        f"-p '{{\"metadata\":{{\"finalizers\":null}}}}' --type=merge"
    )

    # Wait for PVC deletion
    logger.info(f"  Waiting for PVC to delete...")
    if not wait_for_pvc_gone(ns, pvc_name, timeout=20):
        logger.warning(f"  PVC still exists, force deleting...")
        run(f"kubectl delete pvc {pvc_name} -n {ns} --grace-period=0 --force 2>/dev/null")
        time.sleep(5)
        if not wait_for_pvc_gone(ns, pvc_name, timeout=10):
            msg = "PVC won't delete even after force"
            logger.error(f"  {msg} - scaling back up")
            run(f"kubectl scale deploy {deploy} -n {ns} --replicas=1")
            return False, msg

    logger.info(f"  PVC deleted.")

    # Flux reconcile - just annotate to trigger, don't wait for completion
    logger.info(f"  Triggering Flux reconcile...")
    ts = str(int(time.time()))
    run(
        f"kubectl annotate ks {app_name} -n {ns} "
        f"reconcile.fluxcd.io/requestedAt={ts} --overwrite 2>/dev/null"
    )
    if app_name != deploy:
        run(
            f"kubectl annotate ks {deploy} -n {ns} "
            f"reconcile.fluxcd.io/requestedAt={ts} --overwrite 2>/dev/null"
        )

    # Wait for PVC Bound
    logger.info(f"  Waiting for new PVC to bind...")
    phase = wait_for_pvc_bound(ns, pvc_name, timeout=30)
    if phase == "Bound":
        logger.info(f"  PVC recreated and Bound!")
    elif phase == "Pending":
        logger.warning(f"  PVC Pending (Restore populator may need time)")
    else:
        logger.warning(f"  PVC phase={phase}")

    # Scale up
    logger.info(f"  Scaling up {deploy}...")
    run(f"kubectl scale deploy {deploy} -n {ns} --replicas=1")

    # Quick health check
    time.sleep(5)
    status = get_pod_status(ns, app_name)
    logger.info(f"  Pod status: {status}")

    success = phase in ("Bound", "Pending")
    return success, f"phase={phase} pod={status}"


def main():
    start = datetime.now(timezone.utc)
    logger.info(f"Starting PVC fix at {start.isoformat()}")
    logger.info(f"Log file: {LOG_FILE}")

    pvcs = get_terminating_pvcs()
    total = len(pvcs)

    if total == 0:
        logger.info("No Terminating PVCs found. Nothing to do.")
        return

    logger.info(f"Total PVCs to fix: {total}")
    logger.info("=" * 60)

    results = {"fixed": [], "failed": []}

    for idx, (ns, pvc_name) in enumerate(pvcs, 1):
        success, msg = process_pvc(ns, pvc_name, idx, total)
        entry = f"{ns}/{pvc_name}: {msg}"
        if success:
            results["fixed"].append(entry)
        else:
            results["failed"].append(entry)
        logger.info(
            f"  Result: {'OK' if success else 'FAIL'} "
            f"[{len(results['fixed'])} fixed, {len(results['failed'])} failed]"
        )

    # Summary
    elapsed = (datetime.now(timezone.utc) - start).total_seconds()
    logger.info("")
    logger.info("=" * 60)
    logger.info(f"COMPLETE in {elapsed:.0f}s")
    logger.info(f"  Fixed:  {len(results['fixed'])}/{total}")
    logger.info(f"  Failed: {len(results['failed'])}/{total}")

    if results["failed"]:
        logger.info("")
        logger.info("FAILED apps:")
        for entry in results["failed"]:
            logger.info(f"  {entry}")

    # Final verification
    remaining = get_terminating_pvcs()
    if remaining:
        logger.warning(f"\n{len(remaining)} PVCs still Terminating:")
        for ns, name in remaining:
            logger.warning(f"  {ns}/{name}")
    else:
        logger.info("\nAll PVCs cleared!")

    logger.info(f"\nFull log: {LOG_FILE}")


if __name__ == "__main__":
    main()
