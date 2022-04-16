# Ansible Setup for the Backup Server

## Prerequisites

- Create password file
- Input the password for the vault
- Install the ansible-galaxy requirements

```sh
ansible-galaxy install -r requirements.yml
```

## Goal

Server needs to be as simple as possible. Just a dumb Raspberry Pi with a Disk that is meant to receive backups periodically from the clusters.

```sh
ansible-playbook nas.yml -i hosts.yaml --user=rafaribe --extra-vars "ansible_sudo_pass=yourPassword" --vault-password-file "password_file"
```
