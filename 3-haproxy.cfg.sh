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
    default_backend ceph_back
backend ceph_back
    balance roundrobin
EOF

# Add backend servers to HAProxy configuration
for ((i=0; i<${#backend_ips[@]}; i++)); do
    echo "    server ${backend_hostnames[$i]} ${backend_ips[$i]}:$backend_port check" >> /etc/haproxy/haproxy.cfg
done



cat /etc/haproxy/haproxy.cfg 

# cat > /etc/haproxy/haproxy.cfg << EOF
# frontend ceph_front
#     bind 192.168.99.64:8000
#     default_backend ceph_back
# backend ceph_back
#     balance roundrobin
#     server ceph-mon01 192.168.99.64:8443 check
#     server ceph-mon02 192.168.99.65:8443 check
#     server ceph-mon03 192.168.99.66:8443 check
# EOF