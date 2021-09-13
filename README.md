# Ansible role for Backup

This role will setup Restic/Borg backups on a Unix machine for a number of services.

It is inspired by [Ansible role for Restic](https://github.com/angristan/ansible-restic).

## Running the Playbook

```bash
ansible-playbook -i inventory playbook.yaml
```

## Available Scripts
- **nextcloud**: Backs up the nextcloud database (postgresql only) and data from
  `{{ nextcloud_data_path }}`, from the host of a Kubernetes cluster.
  The following variables are required for nextcloud:
  - `nextcloud_enabled`: (default: `false`) Setting to true enables nextcloud
  - `nextcloud_db`: (default: `nextcloud`) The name of the nextcloud database
  - `nextcloud_db_user`: (default: `nextcloud`) The database user
  - `nextcloud_data_path`: (default: `/var/lib/data/nextcloud`) Path on the
    host to the nextcloud data
  - `nextcloud_db_pass`: The database password
  - `nextcloud_repository`: The key of the repository that nextcloud should
    backup to. This can be either a repository that has a list of folders or a
    repository where the folders are set to `[]`
- **general**: Backs up a list of directories specified in either the
  `{{ restic_repositories }}` or `{{ borg_repositories }}` variable.

## Available Variables (Global)

**Working Defaults**:
- `backup_user`: (default: `root`) User to install scripts as
- `backup_user_home`: (default: `/root`) Path to `backup_user`s home directory
- `backup_dailies`: (default: `7`) Number of daily backups to keep
- `backup_weeklies`: (default: `4`) Number of weekly backups to keep
- `backup_monthlies`: (default: `6`) Number of monthly backups to keep
- `ssh_host`: (default: `backup`) Name of host to add to
  `backup_user_home`/.ssh/config
- `ssh_port`: (default: `23`) Port for SSH host (23 because of Hetzner)
- `ssh_private_key_path`: (default: `/root/.ssh/backup`) Path, with filename, 
  for the ssh private key used to connect to remote repository


**No Default and Required**:
- `ssh_user`: (default: none) User for SSH to remote repo
- `ssh_hostname`: (default: none) Hostname for SSH server
- `ssh_private_key`: (default: none) Body of the SSH private key file


## Borg (Preferred)

### Available Variables (Borg Specific)

- `borg`: (default: `false`) Enables or disables borg behaviour, should be
  opposite to `restic`.
- `borg_path`: (default: `/usr/bin/borg`) Path to borg install
- `borg_repositories`: (default: `[]`) Repositories to create borg backup and
  init scripts for. The following fields are **required** for each block (see
  the example below): 
  - `name`: Repository name (Also the path on the remote host)
  - `folders`: A list of paths to backup
  - `excludes`: A list of paths or patterns to exclude (Can be `[]`)
  - `passphrase`: The passphrase to use for the borg repository
  - `key_backup_path`: The full path to store the backup key under
- `borg_prune`: (default: `true`) Whether borg should prune repositories that
  don't meet the keep requirements set in the global variables.

### Example `config.yml`

The following configuration will two scripts:
- A borg init script for the "backup" repository
- A backup script for the "backup" repository

The `/etc`, `/var/lib`, `/opt` and `/home/jb` directories will be included
in the backup and the `/home/jb/.cache` directory will be excluded.
The passphrase will be stored in plain text inside the resulting script, but
the permission restrict visibility to only that user. This decision was made
for easier automation.

```yaml
backup_user: jb
backup_user_home: /home/jb
ssh_private_key_path: /home/jb/.ssh/backup
borg: true
borg_repositories:
  backup:
    name: "backup"
    folders:
      - /etc
      - /var/lib
      - /opt
      - /home/jb
    excludes:
      - /home/jb/.cache
    passphrase: "supersecurepassword"
    key_backup_path: "/home/jb/borg-cappuccino-key.txt"
ssh_user: u123456
ssh_hostname: u123456.your-storagebox.de
ssh_private_key: |-
  -----BEGIN OPENSSH PRIVATE KEY-----
  ...
  -----END OPENSSH PRIVATE KEY-----
```

## Restic (Unstable)

Restic is currently implemented but hasn't worked well for me. Therefore I am
not documenting it for now. If you are determined to use Restic then please dig
through the repository to work out how to use it, and feel free to submit a pull
request if you fix any issues or add documentation.

## Example Inventory File (Included in repository)

The following file will apply the changes on a local machine

```yaml
[all]
127.0.0.1   ansible_connection=local
```
