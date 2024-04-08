# #############################################
#  Usual cmds
# #############################################
```sh
# Enable Ceph cli
cephadm shell

ceph health detail
ceph -s             
ceph df 

ceph orch ls
ceph orch host ls
ceph orch device ls

# All Daemons
ceph orch ps
ceph orch daemon start mon.ceph-mon01

ceph quorum_status -f json-pretty

ceph osd status     : Show OSD (Object Storage Daemon) status.
ceph osd stat -f json-pretty
ceph osd tree       : Display OSD tree.
ceph osd df         : Show OSD utilization.
# Find out on which OSDs was the objects saved
ceph osd map <poolname> <objectname> -f json-pretty
ceph osd map default.rgw.buckets.data dummy_file1.txt -f json-pretty

ceph pg dump        : Dump placement group status.

ceph osd pool ls                     : List pools in the cluster.
ceph osd pool stats <pool_name>      : Show pool statistics.
ceph osd pool get <pool_name> <key>  : Get pool properties.
ceph osd pool get SA-FaultTolerance5-EC-1 crush_rule

radosgw-admin user create: Create RADOS Gateway user.
radosgw-admin bucket list: List RADOS Gateway buckets.

rados -p <pool_name> ls                     : List objects in a pool.
rados -p <pool_name> stat <object_name>     : Show object metadata.
rados -p <pool_name> rm <object_name>       : Remove an object from a pool.