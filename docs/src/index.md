# rafaribe's Homelab

Welcome to my humble homelab.

This git repo is a place where I can experiment with new technologies and ideas. It's stored in a declarative `yaml` format, it's also the source of truth to my kubernetes clusters along with other homelab resources.

This repo utilizes [infrastructure as code](https://www.wikiwand.com/en/Infrastructure_as_code) practices and [GitOps](https://www.redhat.com/en/topics/devops/what-is-gitops) to declare the infrastructure present in my home.

This allows for a interesting workflow:

- Version control any changes allowing for easy refactors, rollbacks and tinkering.
- Easy disaster recovery as everything except persistent data is present in this repo.
- Try out interesting technologies and have that tracked on version control, allowing me to revisit them later even after deletion.

# Tech Stack

<table>
    <tr>
        <th style="width: 15px;"">Logo</th>
        <th><b>Name</b></th>
        <th>Description</th>
    </tr>
    <tr>
        <td><img src="https://simpleicons.org/icons/ansible.svg" alt= "ansible"/></td>
        <td><b>Ansible</b></td>
        <td>Automation tool for configuration management and deployment.</td>
    </tr>
    <tr>
        <td><img src="https://www.svgrepo.com/show/331552/proxmox.svg" alt="proxmox"></td>
        <td><b>Proxmox</b></td>
        <td>Virtualization management platform for multiple VMs and containers.</td>
    </tr>
    <tr>
        <td>
        <img src="https://www.svgrepo.com/show/349542/ubiquiti.svg" alt="proxmox"></td>
        <td><b>Unifi OS</b></td>
        <td>Network management and monitoring software for Ubiquiti devices.</td>
    </tr>
    <tr>
        <td><img src="https://www.svgrepo.com/show/376353/terraform.svg" alt="terraform" ></td>
        <td><b>Terraform</b></td>
        <td> Infrastructure as code tool used to automate the provisioning and management of infrastructure resources.</td>
    </tr>
    <tr>
        <td><img src="https://www.svgrepo.com/show/448233/kubernetes.svg" alt="kubernetes" ></td>
        <td><b>Kubernetes</b></td>
        <td>Container orchestration platform for automating deployment, scaling, and management of containerized applications. T</td>
    </tr>
        <tr>
         <td><img src="https://helm.sh/img/helm.svg" alt="helm"></td>
        <td><b>Helm</b></td>
        <td>The package manager for Kubernetes</td>
    </tr>
    <tr>
        <td><img src="https://www.svgrepo.com/show/373924/nginx.svg" alt="nginx"></td>
        <td><b>NGINX</b></td>
        <td>Nginx-based Kubernetes Ingress controller used to manage external access to Kubernetes cluster services.</td>
    </tr>
    <tr>
         <td><img src="https://fluxcd.io/img/logos/flux-stacked-color.png" alt="flux"></td>
        <td><b>Flux</b></td>
        <td>GitOps continuous delivery tool used to automate application deployments to Kubernetes clusters by managing changes in a Git repository.</td>
    </tr>
    <tr>
         <td><img src="https://cert-manager.io/images/cert-manager-logo-icon.svg" alt="certmanager"></td>
        <td><b>Cert Manager</b></td>
        <td>Kubernetes add-on that automates the management and issuance of TLS certificates from Cloudflare.</td>
    </tr>
        <tr>
         <td><img src="https://www.svgrepo.com/show/331337/cloudflare.svg" alt="cloudflare"></td>
        <td><b>Cloudflare</b></td>
        <td>DNS Provider</td>
    </tr>
    <tr>
         <td><img src="https://www.svgrepo.com/download/354219/prometheus.svg" alt="prometheus"></td>
        <td><b>Prometheus</b></td>
        <td>Monitoring and alerting system used to collect and analyze metrics from various sources in a distributed environment.</td>
    </tr>
        <tr>
         <td><img src="https://github.com/grafana/loki/blob/main/docs/sources/logo.png?raw=true" alt="loki"></td>
        <td><b>Loki</b></td>
        <td>Log aggregation backend</td>
    </tr>
    </tr>
        <tr>
         <td><img src="https://avatars.githubusercontent.com/u/49725059?s=200&v=4" alt="loki"></td>
        <td><b>Thanos</b></td>
        <td>Metrics efficent backend using S3-storage for Prometheus</td>
    </tr>
    </tr>
        <tr>
         <td><img src="https://grafana.com/static/img/menu/grafana2.svg" alt="loki"></td>
        <td><b>Grafana</b></td>
        <td>Dashboard platform</td>
    </tr>
    </tr>
        <tr>
         <td><img src="https://images.g2crowd.com/uploads/product/hd_favicon/72560d7bf99d51bc45794936cc945ba7/doppler-secretops-platform.svg" alt="loki"></td>
        <td><b>Doppler</b></td>
        <td>External Secrets Provider</td>
    </tr>
    </tr>
        <tr>
         <td><img src="https://layer5.io/static/67e20231adeb31cc1a6076aed4651e46/cilium-color.svg" alt="loki"></td>
        <td><b>Cilium</b></td>
        <td>CNI with eBPF-based networking, observability and security</td>
    </tr>
</table>

© All images are copyright to their respective owners and are protected under international copyright laws.
