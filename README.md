# Ansible role for Backup

This role will setup Restic backups on a Unix machine for a number of services.

It is inspired by [Ansible role for Restic](https://github.com/angristan/ansible-restic).

## Available Scripts

- **nextcloud**: Backs up the nextcloud database (postgresql only) and data from
  {{ nextcloud_data_path }}, from the host of a Kubernetes cluster.

## Example Playbook

```yaml
---

- hosts: myhost
  roles: restic
  vars:
    restic_ssh_user: u123456
    restic_ssh_hostname: u123456@u123456.server.ltd
    restic_repositories:
        photos:
            name: "photos"
            password: "picspass"
        general:
            name: "general"
            password: "superpass1"
        nextcloud:
            name: "nextcloud"
            password: "nextcloud"
    restic_folders:
        - {path: "/home/jb/documents", repo: "general"}
        - {path: "/mnt/hdd/photos", repo: "photos"}
    restic_ssh_private_key: |-
      -----BEGIN OPENSSH PRIVATE KEY-----
      b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
      QyNTUxOQAAACAocs5g1I4kFQ1HH/YZiVU+zLhRDu4tfzZ9CmFAfKhL2AAAAJi02XEwtNlx
      MAAAAAtzc2gtZWQyNTUxOQAAACAocs5g1I4kFQ1HH/YZiVU+zLhRDu4tfzZ9CmFAfKhL2A
      AAAEADZf2Pv4G74x+iNtuwSV/ItnR3YQJ/KUaNTH19umA/tChyzmDUjiQVDUcf9hmJVT7M
      uFEO7i1/Nn0KYUB8qEvYAAAAE3N0YW5pc2xhc0BtYnAubG9jYWwBAg==
      -----END OPENSSH PRIVATE KEY-----
    nextcloud_data_path: /var/lib/data/nextcloud
    nextcloud_database_password: 12345678
    nextcloud_repository: nextcloud
```
