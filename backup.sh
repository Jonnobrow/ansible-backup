#!/bin/sh

usage() {
    printf "%s"\
"The backup script enables maintenance mode, backs up the data
and database and then disables maintenance mode.

Usage: $1 [flags]

Flags:
    -h                  show the help text

    -n path             path to nextcloud directory on host (default: /var/lib/data/nextcloud)

    -r repository       repository to backup to (default: \$RESTIC_REPOSITORY)
    -e pattern          exclude a pattern (default: )

    -d database         name of database to backup (default: nextcloud)
    -u user             name of database user (default: nextcloud)
    -p password         database password (default: )
"
exit 2
}

# Path on host to nextcloud volume
NCPATH="/var/lib/data/nextcloud"

# Restic Opts
RESTIC_REPOSITORY=$RESTIC_REPOSITORY
RESTIC_EXCLUDE=

# DATABASE OPTS
DB="nextcloud"
DB_USER="nextcloud"
DB_PASS=""

while getopts n:r:e:d:u:p:h opt; do
    case $opt in
    n) NCPATH=$OPTARG;;
    r) RESTIC_REPOSITORY=$OPTARG;;
    e) RESTIC_EXCLUDE=$OPTARG;;
    d) DB=$OPTARG;;
    u) DB_USER=$OPTARG;;
    p) DB_PASS=$OPTARG;;
    h|?) usage ;; esac
done

### Enable Maintenance Mode {
POD=$(kubectl get pods -n nextcloud \
      -l app.kubernetes.io/component=app -o name)
kubectl exec -n nextcloud $POD -- \
    su - -s '/bin/sh' www-data -c \
        "php -d memory_limit=-1 \
         /var/www/html/occ maintenance:mode --on" \
    >/dev/null 2>&1 
### }

### Backup Nextcloud Data {
restic backup                       \
    --exclude="$RESTIC_EXCLUDE"     \
    --repo="$RESTIC_REPOSITORY"     \
    --verbose                       \
    $NCPATH/config                  \
    $NCPATH/data                    \
    $NCPATH/themes                  
### }

### Backup Nextcloud Database {
POD=$(kubectl get pods -n nextcloud \
      -l app.kubernetes.io/name=postgresql -o name)
kubectl exec -n nextcloud $POD --                       \
    /bin/bash -c "PGPASSWORD=$password                  \
                 /opt/bitnami/postgresql/bin/pg_dump    \
                 -U$username $database"                 \
    | restic backup                                         \
        --repo="$RESTIC_REPOSITORY"                         \
        --verbose                                           \
        --stdin                                             \
        --stdin-filename "$database-database.bak.sql"
### }
 
### Disable Maintenance Mode {
POD=$(kubectl get pods -n nextcloud \
      -l app.kubernetes.io/component=app -o name)
kubectl exec -n nextcloud $POD -- \
    su - -s '/bin/sh' www-data -c \
        "php -d memory_limit=-1 \
         /var/www/html/occ maintenance:mode --off" \
    >/dev/null 2>&1 
### }
