# Ansible Setup for the Backup Server

## Prerequisites
- Create password file
- Input the password for the vault

Server needs to be as simple as possible. Just a dumb Raspberry Pi with a Disk that is meant to receive backups periodically from the clusters.

```sh
ansible-playbook playbook.yml -i hosts.yaml --user=rafaribe --extra-vars "ansible_sudo_pass=yourPassword" --vault-password-file "password_file"
```