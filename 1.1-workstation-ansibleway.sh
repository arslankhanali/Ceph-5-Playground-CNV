ssh -L 8000:localhost:8000 -L 9000:localhost:9000 lab-user@ssh.ocpvdev01.dal10.infra.demo.redhat.com -p 30087

# Green
sudo su
echo 'export PS1="\[\e[0;32m\][\u@\h \W]\$ \[\e[m\]"' >> ~/.bashrc
source ~/.bashrc


# Execute a command on all hosts
dnf install ansible-core

cat >  /etc/ansible/hosts  << EOF
[cluster1]
ceph-mon01
ceph-mon02
ceph-mon03
[cluster2]
ceph-node01
ceph-node02
ceph-node03
EOF

cat >  execute_commands.yaml  << EOF
---
- name: Enable logging in via root
  hosts: all
  gather_facts: no
  remote_user: cloud-user
  become: yes

  tasks:
    - name: Execute commands via SSH
      command: "sed -i 's/^.*no-port-forwarding,no-agent-forwarding,no-X11-forwarding,command=\"echo.*exit 142\" //' /root/.ssh/authorized_keys"
EOF

ansible all -m ping
ansible-playbook -i /etc/ansible/hosts execute_commands.yml