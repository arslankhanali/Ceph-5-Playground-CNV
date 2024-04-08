# ssh -L 8000:localhost:8000 -L 9000:localhost:9000 lab-user@ssh.ocpvdev01.dal10.infra.demo.redhat.com -p 30087
ssh -L 8000:localhost:8000 -L 9000:localhost:9000 -L 8888:localhost:8888 -L 9999:localhost:9999 lab-user@ssh.ocpvdev01.dal10.infra.demo.redhat.com -p 30087

# Green
sudo su
echo 'export PS1="\[\e[0;32m\][\u@\h \W]\$ \[\e[m\]"' >> ~/.bashrc
source ~/.bashrc

# Execute a command on all hosts
cat >  commands.txt  << EOF
sudo su
sed -i 's/^.*no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command="echo.*exit 142" //' /root/.ssh/authorized_keys
EOF

hostnames=("ceph-mon01" "ceph-mon02" "ceph-mon03" "ceph-node01" "ceph-node02" "ceph-node03")
for hostname in "${hostnames[@]}"; do ssh cloud-user@"$hostname" 'bash -s' < commands.txt; done