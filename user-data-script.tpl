#!/bin/bash
set -o xtrace

# Configure containerd before bootstrap
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl enable containerd
systemctl start containerd

# Set up required kernel parameters
cat << EOF > /etc/sysctl.d/99-kubernetes.conf
net.bridge.bridge-nf-call-iptables=1
net.ipv4.ip_forward=1
net.bridge.bridge-nf-call-ip6tables=1
net.ipv4.tcp_keepalive_time=60
#net.core.somaxconn=32768
EOF
sysctl --system

# Bootstrap and join the cluster
/etc/eks/bootstrap.sh ${cluster_name} \
  --b64-cluster-ca ${cluster_auth_base64} \
  --apiserver-endpoint ${cluster_endpoint} \
  ${bootstrap_extra_args}

# Configure kubelet settings
mkdir -p /etc/systemd/system/kubelet.service.d
cat << EOF > /etc/systemd/system/kubelet.service.d/30-kubelet-extra-args.conf
[Service]
Environment="KUBELET_EXTRA_ARGS=${kubelet_extra_args}"
EOF

# Restart kubelet to apply changes
systemctl daemon-reload
systemctl restart kubelet

# Install necessary packages
yum update -y
yum install -y \
    containerd \
    ec2-instance-connect \
    conntrack \
    nfs-utils \
    socat \
    jq \
    python3 \
    python3-pip \
    nano \
    htop \
    iptables-services
    #docker

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# # Configure Docker as secondary runtime
# systemctl enable docker
# systemctl start docker