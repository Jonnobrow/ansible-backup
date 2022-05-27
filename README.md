# Ansible role for Backup

This role will setup Borg backups on a Unix machine for a number of services.

It is inspired by [Ansible role for Restic](https://github.com/angristan/ansible-restic).

## Usage

1. Clone the repo: `git clone https://github.com/Jonnobrow/ansible-backup.git`
2. Replace the key in the provided [sops](https://github.com/mozilla/sops) config with you gpg key:
   ```bash
   export MY_KEY_FP=whatever_you_key_fingerprint_is
   sed -i "s/DE99604016EF8893AD54FDE83BC85C121EA96233/${MY_KEY_FP}/g" .sop.yaml
   ```
3. Create an inventory subdirectory (e.g. `./inventory/your-clustername`)
4. Copy and modify the `./inventory/coffee-shop/hosts.yaml` to list your hosts
   ```yaml
   ---
   all:
     hosts:
       server1:
       server2:
   ```
5. Create a yaml file for each server under `./inventory/your-clustername/host_vars/` (e.g. `server1.sops.yml`):

   ```yaml
   # IP address of node
   ansible_host: 192.168.4.3
   ansible_user: ubuntu

   # Settings
   borg: true
   borg_repositories:
     server1:
       name: mocha
       folders:
         - /var/lib/rancher/k3s/storage/
         - /var/lib/data/mealie
         - /var/lib/data/paperless
         - /var/lib/data/jellyfin
         - /var/lib/data/photoprism
         - /etc
       excludes:
         - /var/lib/data/photoprism/sidecar*
         - /var/lib/data/photoprism/cache*
       passphrase:
       key_backup_path: borg-server1-key.txt
   ssh_user:
   ssh_hostname:
   ssh_private_key: |-
     -----BEGIN OPENSSH PRIVATE KEY-----
     ...
     -----END OPENSSH PRIVATE KEY-----
   nextcloud_enabled: true
   nextcloud_data_path: /var/lib/data/nextcloud
   nextcloud_db_pass:
   nextcloud_repository: server1
   ```

6. Encrypt each `host_var` file with `sops`:
   ```bash
   sops -e -i ./inventory/your-clustername/host_vars/server1.sops.yml
   ```
7. Run the task (uses [taskfile](https://taskfile.dev/#/))
   ```bash
   task playbook:backup-install
   ```
