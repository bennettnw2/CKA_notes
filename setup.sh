# Run this as the root user

swapoff -a
sed -i /swap/d /etc/fstab

cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sysctl --system

#Install containerd...we need to install from the docker repo to get containerd 1.6, the ubuntu repo stops at 1.5.9
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y containerd.io

#Create a containerd configuration file
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml

#Set the cgroup driver for containerd to systemd which is required for the kubelet.
#For more information on this config file see:
# https://github.com/containerd/cri/blob/master/docs/config.md and also
# https://github.com/containerd/containerd/blob/master/docs/ops.md
#You can use sed to swap in true
sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml

#Restart containerd with the new configuration
systemctl restart containerd

#Install Kubernetes packages - kubeadm, kubelet and kubectl
#Add Google's apt repository gpg key
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg

#Add the Kubernetes apt repository
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list


#Update the package list and use apt-cache policy to inspect versions available in the repository
apt-get update
apt-cache policy kubelet | head -n 20


#Install the required packages, if needed we can request a specific version.
#Use this version because in a later course we will upgrade the cluster to a newer version.
#Try to pick one version back because later in this series, we'll run an upgrade
VERSION=1.26.0-00
apt-get install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION
apt-mark hold kubelet kubeadm kubectl containerd

systemctl enable kubelet.service
systemctl enable containerd.service



# Adding user for system
adduser [username]
usermod -aG sudo [username]
# scp my .vimrc
# git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
