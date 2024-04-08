
# Variables CEPH-CLUSTER-2
export rgw_realm="pakistan"
export zonegroup_name="punjab"
export zone_name="pindi"
export endpoints="192.168.99.61"
export access_key="FROM-USER-YOU-CREATED-ON-CLUSTER-1" # notsecret
export secret_key="NOTAREALSECRET" # notsecret
export placement="3 ceph-node01 ceph-node02 ceph-node03"
export primarycluster="http://192.168.99.64:80"

# Commands
radosgw-admin realm pull --rgw-realm=$rgw_realm --url=$primarycluster --access-key=$access_key --secret-key=$secret_key --default

# Let pull zonegroup and zone from primary ceph cluster
radosgw-admin period pull --url=$primarycluster --access-key=$access_key --secret-key=$secret_key 

radosgw-admin zone create --rgw-zonegroup=$zonegroup_name \
             --rgw-zone=$zone_name --endpoints=$endpoints \
             --access-key=$access_key --secret=$secret_key 

radosgw-admin period update --commit

ceph orch apply rgw $zone_name --realm=$rgw_realm --zone=$zone_name --placement="$placement"


# If you want to delete default zonegroup, zones and pools
radosgw-admin zonegroup remove --rgw-zonegroup=default --rgw-zone=default
radosgw-admin zone delete --rgw-zone=default
radosgw-admin zonegroup delete --rgw-zonegroup=default
ceph config set mon mon_allow_pool_delete true
ceph osd pool rm default.rgw.log default.rgw.log --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.meta default.rgw.meta --yes-i-really-really-mean-it
ceph osd pool rm default.rgw.control default.rgw.control --yes-i-really-really-mean-it


# To test
# Use http instead of https
# curl -k http://localhost:80/
# curl -k http://localhost:9999/

# radosgw-admin sync status

# ceph config set global rgw_dynamic_resharding true