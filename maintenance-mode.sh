#!/bin/sh

action=

usage(){
    printf 'Usage: %s -0|-1' "$0"
}

while getopts 01 opt; do
    case $opt in
    0) action="off";;
    1) action="on";;
    *) 
        usage
        exit 2
        ;;
    esac
done

if [ -n "$action" ]; then
    POD=$(kubectl get pods -n nextcloud \
          -l app.kubernetes.io/component=app -o name)
    kubectl exec -n nextcloud $POD -- \
        su - -s '/bin/sh' www-data -c \
            "php -d memory_limit=-1 \
             /var/www/html/occ maintenance:mode --$action" \
        >/dev/null 2>&1 
else
    usage
fi
