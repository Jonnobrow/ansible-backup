#!/bin/sh
POD=$(kubectl get pods -n nextcloud \
      -l app.kubernetes.io/name=postgresql -o name)

username="nextcloud"
password=""
database="nextcloud"

usage(){
    printf 'Usage: %s -u|-p|-d' "$0"
    exit 2
}

while getopts u:p:d:h opt; do
    case $opt in
    u) username=$OPTARG;;
    p) password=$OPTARG;;
    d) database=$OPTARG;;
    ?|h) usage ;;
    esac
done

if [ -n "$username" ] || [ -n "$database" ]; then
    kubectl exec -n nextcloud $POD -- \
        /bin/bash -c "PGPASSWORD=$password\
                     /opt/bitnami/postgresql/bin/pg_dump\
                     -U$username $database" \
    | restic backup \
        --verbose \
        --stdin \
        --stdin-filename "$database-database.bak.sql"
fi
