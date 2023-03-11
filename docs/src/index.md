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
        <td>Logo</td>
        <td>Name</td>
        <td>Description</td>
    </tr>
    <tr>
        <td> <img src="https://simpleicons.org/icons/ansible.svg" alt= “ansible” width="15%" height="15%"></td>
        <td>Ansible</td>
        <td>Automation tool for configuration management and deployment.</td>
    </tr>
    <tr>
        <td><img src="https://www.svgrepo.com/show/331552/proxmox.svg" alt="proxmox" width="15%" height="15%"></td>
        <td>Proxmox</td>
        <td>Virtualization management platform for multiple VMs and containers.</td>
    </tr>
    <tr>
        <td>
        <img src="https://www.svgrepo.com/show/349542/ubiquiti.svg" alt="proxmox" width="15%" height="15%"></td>
        <td>Unifi OS</td>
        <td>Network management and monitoring software for Ubiquiti devices.</td>
    </tr>
    <tr>
        <td><img src="https://www.svgrepo.com/show/376353/terraform.svg" alt="terraform" width="20%" height="20%"></td>
        <td>Terraform</td>
        <td> Infrastructure as code tool used to automate the provisioning and management of infrastructure resources.</td>
    </tr>
    <tr>
        <td><img src="https://www.svgrepo.com/show/448233/kubernetes.svg" alt="kubernetes" width="15%" height="15%"></td>
        <td>Kubernetes</td>
        <td>Container orchestration platform for automating deployment, scaling, and management of containerized applications.</td>
    </tr>
    <tr>
        <td><img src="https://www.svgrepo.com/show/373924/nginx.svg" alt="nginx" width="15%" height="15%"></td>
        <td>NGINX</td>
        <td>Nginx-based Kubernetes Ingress controller used to manage external access to Kubernetes cluster services.</td>
    </tr>
    <tr>
         <td><img src="https://cncf-branding.netlify.app/img/projects/flux/icon/color/flux-icon-color.svg" alt="nginx" width="10%" height="10%"></td>
        <td>Flux</td>
        <td>GitOps continuous delivery tool used to automate application deployments to Kubernetes clusters by managing changes in a Git repository.</td>
    </tr>
</table>

© All images are copyright to their respective owners and are protected under international copyright laws.
