# In lab doing it on node02 because it does not have mgr on it and only port 8443 is accessable  in lab. Cant access port 80 directly:(
ssh root@ceph-node01

dnf -y install haproxy

# Fix Selinux to make ports bindable
getsebool -a | grep haproxy
setsebool -P haproxy_connect_any=1

#!/bin/bash
# Frontend (local host)
frontend_ip="192.168.99.61"
frontend_port="9000"

# Backend server details
backend_ips=("192.168.99.61" "192.168.99.62" "192.168.99.63")
backend_hostnames=("ceph-node01" "ceph-node02" "ceph-node03")
backend_port="8443"

# Generate HAProxy configuration dynamically
cat > /etc/haproxy/haproxy.cfg << EOF
frontend ceph_front
    bind $frontend_ip:$frontend_port
    default_backend ceph_back
backend ceph_back
    balance roundrobin
EOF

# Add backend servers to HAProxy configuration
for ((i=0; i<${#backend_ips[@]}; i++)); do
    echo "    server ${backend_hostnames[$i]} ${backend_ips[$i]}:$backend_port check" >> /etc/haproxy/haproxy.cfg
done

# Start HAPROXY
systemctl restart haproxy

curl -k https://$frontend_ip:$frontend_port
