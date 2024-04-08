# PURGE CEPH CLUSTER
#rm -f /root/.ssh/known_hosts
ceph orch pause

# Get the fsid of the cluster from /etc/ceph/ceph.conf file and run the below command.
# RHEL 9
ceph fsid
ansible -i /etc/ansible/hosts all -m shell -a "cephadm rm-cluster --force --fsid ,de9e18f2-d908-11ee-adfd-2cc260754989" -f 10
ansible -i /etc/ansible/hosts cluster1 -m shell -a "cephadm rm-cluster --force --fsid ,de9e18f2-d908-11ee-adfd-2cc260754989" -f 10

# RHEL 8

cat > /root/cephadm-ansible/hosts << EOF
[admin]
ceph-mon01.example.com

[clients]
ceph-mon02.example.com
ceph-node03.example.com
proxy01.example.com

[cluster1]
ceph-mon01.example.com
ceph-mon02.example.com
ceph-node03.example.com
proxy01.example.com
EOF

cat /etc/ceph/ceph.conf |grep -i fsid
ansible-playbook -i hosts cephadm-purge-cluster.yml -e fsid=0f5f5662-d91e-11ee-b107-2cc260754989 -vvv