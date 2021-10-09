# Ansible role for Backup

This role will setup Borg backups on a Unix machine for a number of services.

It is inspired by [Ansible role for Restic](https://github.com/angristan/ansible-restic).

## Available Scripts

- **nextcloud**: Backs up the nextcloud database (postgresql only) and data from
  {{ nextcloud_data_path }}, from the host of a Kubernetes cluster.
