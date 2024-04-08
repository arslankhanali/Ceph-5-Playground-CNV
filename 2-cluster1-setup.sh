# For CEPH-CLUSTER-1
ssh lab-user@ssh.ocpvdev01.dal10.infra.demo.redhat.com -p 30087

sudo su
ssh -L 8000:localhost:8443 -L 8888:localhost:80 root@ceph-mon01

# Yellow
echo 'export PS1="\[\e[0;33m\][\u@\h \W]\$ \[\e[m\]"' >> ~/.bashrc
source ~/.bashrc

dnf -y install git ansible

git clone https://github.com/ceph/cephadm-ansible.git
cd cephadm-ansible

cat > /etc/ansible/hosts << EOF
[cluster1]
ceph-mon01
ceph-mon02
ceph-mon03
[cluster2]
ceph-node01
ceph-node02
ceph-node03
EOF

ansible-playbook -i /etc/ansible/hosts -l cluster1 cephadm-preflight.yml

cephadm bootstrap --mon-ip 192.168.99.64 --allow-fqdn-hostname
# URL: https://ceph-mon01:8443/
#             User: admin
#         Password: 9kww9jnpms
# curl -k https://192.168.56.64:8443
# curl -k https://192.168.99.64:8443

ssh-copy-id -o StrictHostKeyChecking=no -f -i /etc/ceph/ceph.pub root@ceph-mon02
ssh-copy-id -o StrictHostKeyChecking=no -f -i /etc/ceph/ceph.pub root@ceph-mon03

ceph orch host add ceph-mon02 192.168.99.65
ceph orch host add ceph-mon03 192.168.99.66

ceph orch apply osd --all-available-devices

echo "admin@123" > dashboard_password.yml
ceph dashboard ac-user-set-password admin -i dashboard_password.yml

ceph orch upgrade start --image quay.io/ceph/ceph:v18.2.1
# ceph --version
# ceph orch upgrade status

# cephadm shell
# ceph health detail
# ceph -s             
# ceph df 
# ceph osd tree 

# curl -k https://localhost:8443/
# https://localhost:8000/

# ceph config set mon mon_max_pg_per_osd 224