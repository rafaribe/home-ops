<div align="center">

<img src="https://raw.githubusercontent.com/rafaribe/home-ops/476a33622545cf385bbd55cf803965bc25d4ae16/docs/src/images/logo.png" align="center" width="144px" height="144px"/>

### My home operations repository :octocat:

_... managed with Flux, Renovate and GitHub Actions_ :robot:

</div>


<div align="center">

[![Docs](https://img.shields.io/static/v1.svg?color=009688&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=Homelab&message=Docs&logo=readthedocs)](https://rafaribe.github.io/home-ops/ "Documentation for this repository.")
[![GitHub stars](https://img.shields.io/github/stars/rafaribe/home-ops?color=green&style=for-the-badge)](https://github.com/rafaribe/home-ops/stargazers "This repo star count")
[![GitHub last commit](https://img.shields.io/github/last-commit/rafaribe/home-ops?color=purple&style=for-the-badge)](https://github.com/rafaribe/home-ops/commits/main "Commit History")

</div>

<div align="center">

[![Discord](https://img.shields.io/discord/673534664354430999?style=for-the-badge&label&logo=discord&logoColor=white&color=blue)](https://discord.gg/home-operations)&nbsp;&nbsp;
[![Talos](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.rafaribe.com%2Ftalos_version&style=for-the-badge&logo=talos&logoColor=white&color=blue&label=%20)](https://talos.dev)&nbsp;&nbsp;
[![Kubernetes](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.rafaribe.com%2Fkubernetes_version&style=for-the-badge&logo=kubernetes&logoColor=white&color=blue&label=%20)](https://kubernetes.io)&nbsp;&nbsp;
[![Renovate](https://img.shields.io/github/actions/workflow/status/onedr0p/home-ops/renovate.yaml?branch=main&label=&logo=renovatebot&style=for-the-badge&color=blue)](https://github.com/rafaribe/home-ops/actions/workflows/renovate.yaml)

</div>

<div align="center">

[![Age-Days](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.rafaribe.com%2Fcluster_age_days&style=flat-square&label=Age)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Uptime-Days](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.rafaribe.com%2Fcluster_uptime_days&style=flat-square&label=Uptime)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Node-Count](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.rafaribe.com%2Fcluster_node_count&style=flat-square&label=Nodes)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Pod-Count](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.rafaribe.com%2Fcluster_pod_count&style=flat-square&label=Pods)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![CPU-Usage](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.rafaribe.com%2Fcluster_cpu_usage&style=flat-square&label=CPU)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
[![Memory-Usage](https://img.shields.io/endpoint?url=https%3A%2F%2Fkromgo.rafaribe.com%2Fcluster_memory_usage&style=flat-square&label=Memory)](https://github.com/kashalls/kromgo)&nbsp;&nbsp;
</div>


---

## :book:&nbsp; Overview

This is the repository that hosts the code that I use to manage my home infrastructure.

I use **Debian 12**  as my base OS and **k3s** as my Kubernetes distribution. [Ansible](https://www.ansible.com/) is used to provision the [k3s](https://k3s.io) cluster along with some basic debugging tooling on the nodes and to provision my `backup-server`.
After the kubernetes cluster is provisioned I use [Flux](https://fluxcd.io/) to watch this repository, and [Renovate](https://renovate.io/) to automatically update the dependencies.

## :wrench:&nbsp; Tools

_Below are some of the tools I find useful_

| Tool                                                            | Purpose                                                                              |
|-----------------------------------------------------------------|--------------------------------------------------------------------------------------|
| [sops](https://github.com/mozilla/sops)                         | Simple and flexible tool for managing secrets                                        |
| [pre-commit](https://github.com/pre-commit/pre-commit)          | Ensure the YAML and shell script in my repo are consistent                           |
| [kubesearch](https://kubesearch.dev/)                           | Look for how other people manage their Self-hosted software on k8s-at-home community |
| [mkdocs material](https://squidfunk.github.io/mkdocs-material/) | Static website generator for all my docs in this repo                                |
| [Renovate](https://docs.renovatebot.com/)                       | Automatically finds new releases for the applications and issues corresponding PR's  |


## :handshake:&nbsp; Thanks

A lot of inspiration for my cluster came from the people that have shared their clusters over at [kubernetes at home community](https://github.com/k8s-at-home)

- [xUnholy/k8s-gitops](https://github.com/xUnholy/k8s-gitops)
- [billimek/k8s-gitops](https://github.com/billimek/k8s-gitops)
- [carpenike/k8s-gitops](https://github.com/carpenike/k8s-gitops)
- [rust84/k8s-gitops](https://github.com/rust84/k8s-gitops)
- [blackjid/homelab-gitops](https://github.com/blackjid/homelab-gitops)
- [bjw-s/k8s-gitops](https://github.com/bjw-s/k8s-gitops)
- [toboshii/k8s-gitops](https://github.com/toboshii/k8s-gitops)
- [onedr0p/home-ops](https://github.com/onedr0p/home-ops)
- [Truxnell/home-cluster](https://github.com/Truxnell/home-cluster)
- [haraldkoch/kochhaus-home](https://github.com/haraldkoch/kochhaus-home)
- [auricom/home-ops](https://github.com/auricom/home-ops)

And to the projects that I use every day to help make my cluster better:

- [Kubesearch](https://kubesearch.dev/)
- [Flux-Local](https://github.com/allenporter/flux-local)
- [Home Operations Discord](https://discord.gg/qBnQsM3y)

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=rafaribe/home-ops&type=Date)](https://star-history.com/#rafaribe/home-ops&Date)

Test
