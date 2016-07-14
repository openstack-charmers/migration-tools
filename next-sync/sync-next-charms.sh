#!/bin/bash
#
# Update -next charms branches.
#
# This branches the -next charms from ~openstack-charmers and push them to
# ~openstack-charmers-next so that they're visible
# in the charm store.
#
# If the "check" command is used, for each charm it will be reporte whether it
# need updating.
#
SCRIPT=$(basename $0)


SOURCE_RELEASE=trusty
TARGET_RELEASES="precise trusty xenial"

CHARMS="
ceilometer
ceilometer-agent
ceph
ceph-osd
ceph-mon
ceph-radosgw
cinder
cinder-ceph
glance
hacluster
heat
keystone
neutron-api
neutron-api-odl
neutron-gateway
neutron-openvswitch
nova-cloud-controller
nova-compute
openstack-dashboard
percona-cluster
swift-proxy
swift-storage
rabbitmq-server
lxd
odl-controller
openvswitch-odl
cisco-vpp
glance-simplestreams-sync
"

NEXT_CHARMS_BASE_URL="lp:~openstack-charmers-next/charms"


upstream_charm_next_url() {
    echo "lp:~openstack-charmers/charms/${SOURCE_RELEASE}/${1}/next"
}

charm_next_url() {
    echo "${NEXT_CHARMS_BASE_URL}/${2}/${1}/trunk"
}

update_charm() {
    (set -e
     local charm="$1"
     local upstream_url=$(upstream_charm_next_url $charm)
     for target_release in $TARGET_RELEASES; do
         local next_url=$(charm_next_url $charm $target_release)
         echo "Examining $charm charm for $target_release ... "
         if has_missing_revisions $next_url $upstream_url; then
             echo " updating $upstream_url -> $next_url"
             bzr pull -q -d $next_url --overwrite $upstream_url || {
                echo " target branch missing, creating initial branch $upstream_url -> $next_url"
                bzr branch -q $upstream_url $next_url
             }
         else
             echo " up to date"
         fi
     done
    )
}

# Returns whether the source branch has newer revisions than the target one
has_missing_revisions() {
    local target="$1"
    local source="$2"
    bzr missing -d $source $target >/dev/null 2>&1
    [ $? -eq 0 ] && return 1 || return 0
}

upstream_charm_changed() {
    local charm="$1"
    has_missing_revisions $(charm_next_url $charm) $(upstream_charm_next_url $charm)
}

usage() {
    cat <<EOF
Usage: $SCRIPT [-uy] [charm-names...]

  -u   update charms (by default update check is performed)
  -y   confirm operation

EOF
    exit
}

action="check"

while getopts ":yuh" opt; do
    case $opt in
        y) confirm=1 ;;
        u) action="update" ;;
        h) usage ;;
        \?)
            echo "Invalid option '-$OPTARG'"
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

[ $# -gt 0 ] && charms="$@" || charms="$CHARMS"

if [ $action = "update" -a -z "$confirm" ]; then
    # Ask confirmation to push branches
    read -p  "This will update branches under \
${LANDSCAPE_NEXT_CHARMS_BASE_URL} if there are updates, confirm? [yN] " res
    case $res in
        [Yy]* ) ;;
        * ) exit 1
    esac
fi

for charm in $charms; do
    if [ $action = "update" ]; then
        update_charm $charm
    else
        echo -ne "$charm ... "
        upstream_charm_changed $charm && echo "UPDATE" || echo "ok"
    fi
done
