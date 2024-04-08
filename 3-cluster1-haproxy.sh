# In lab doing it on mon01 because it does not have mgr on it and only port 8443 is accessable  in lab. Cant access port 80 directly:(
ssh root@ceph-mon01

# Install HAPROXY
dnf -y install haproxy

# Change SELINUX to make ports bindable
getsebool -a | grep haproxy
setsebool -P haproxy_connect_any=1

######################################################
#!/bin/bash
# Frontend (local host)
frontend_ip="192.168.99.64"
frontend_port="8000"

# Backend server details
backend_ips=("192.168.99.64" "192.168.99.65" "192.168.99.66")
backend_hostnames=("ceph-mon01" "ceph-mon02" "ceph-mon03")
backend_port="8443"

# Generate HAProxy configuration dynamically
cat > /etc/haproxy/haproxy.cfg << EOF
frontend ceph_front
    bind $frontend_ip:$frontend_port
    bind 127.0.0.1:$frontend_port
    default_backend ceph_back

backend ceph_back
    balance roundrobin
EOF

# Add backend servers to HAProxy configuration
for ((i=0; i<${#backend_ips[@]}; i++)); do
    echo "    server ${backend_hostnames[$i]} ${backend_ips[$i]}:$backend_port check" >> /etc/haproxy/haproxy.cfg
done

######################################################
# Verify config file - Last line should say "Configuration file is valid"
haproxy -c -f /etc/haproxy/haproxy.cfg
cat /etc/haproxy/haproxy.cfg

# Start HAPROXY
systemctl restart haproxy
systemctl enable  haproxy
systemctl status haproxy

# Manual Test with curls
curl -k https://192.168.99.64:8000
curl -k https://localhost:8000
curl -k https://localhost:8443

i=0
curl -k https://${backend_ips[$i]}:${backend_port[0]}

###########
# TEST
###########
# Open ports
netstat -tuln | grep ':8443'
netstat -tuln | grep ':8000'

# # Export public IP
# public_ip=$(curl -s ifconfig.co)

# # Perform CURL to the public IP
# public_output=$(curl -s -o /dev/null -w "%{http_code}" $public_ip:$frontend_port)

