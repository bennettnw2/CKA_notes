# Installing and Configuring Kubernetes

## Installation Considerations
What do I need to know and do to install kubernetes?

Where to install?
- Cloud
    - IaaS - Virtual Machines
        - install everything from scratch
        - take on more responsiblity administering the cluster
    - PaaS - Managed Service
        - Control Plane is managed for you
        - Not as flexible as IaaS offering
            - versioning
- On-Premises
    - Bare Metal
    - Virtual Machines

Which offering to choose?
- Depends on the skills and strategies of the organization

Cluster Networking
- Use overlay network?
- Use network team to make sure we have correct L2 and L3 connectivity
- IP addressing; no overlaps in IP ranges/addresses

Scalability
- Do we have enough nodes in our cluster for our workload?
- Do we have enough resources to manage our cluster?
- Do we have enough nodes in the event of a node failure?

High Availability
- We will need more than one control plane to ensure uptime?
- Have replicas of the API server back with multiple copies of etcd to provide redundancy for both the API and the etcd data store.

Disaster Recovery
- Ensure we have backup and recovery of the etcd data store in event of catastrophic failure.

## Installation Methods

Desktop Installation
- Great for developemnt environments
- Great for testing new ideas
- Great for troubleshooting

kubeadm

Cloud Scenarios
- IaaS
- PaaS

## Installation Requirements

System Requirements
- Linux - Ubuntu/RHEL
- 2 CPUs
- 2 GB RAM
- Diable Swap

Container Runtime
- Container Runtime Interface
- containerd
- Docker
- CRI-O

Networking
- Connectivity between all nodes
- Unique Hostname for each system?
- Unique Mac Address for each system?

# Understanding Cluster Networking

## Cluster Network Ports
The control plane node provides a collection of services such as the API server, etcd, etc.. Worker nodes need to access the API server. Specifically the kubelet and the kube-proxy on worker nodes will talk to the API server over TCP/IP. We are going to go over the cluster components and discuss the ports that are required and who uses those ports so that we can develop firewall rules to help keep the cluster secure.

   ![](imgs/clusterNetworkPorts.png)

In case you have a firewall or other security, these are the ports that you will need to open.
- The API server, by default, runs on port 6443. Can configure this to any port, but this is the default. Anthing and everything will need to connect to the API server; even me using kubectl!
- etcd runs on 2379 & 2380. The API server will need to talk to etcd because the it persists its data there.
    - If you have a redundant configuration of etcd, the vairous replicas of etcd will need to communicate with each other over these ports
    - This is why you see the API and etcd needs to communicate with etcd
- The scheduler runs on port 10251 and it's used only by itself. The port it listens on is 10251 but only on localhost. It is not exposed to the outside world.
- The controller manager is the same as the scheduler. It is listening for requests on port 10252 but only on localhost.
- Lastly on the control plane node is the kubelet on port 10250 and all the control plane components need access to it inside of our kubernetes cluster.
- On workers nodes, the kubelet also runs on port 10250 and control plane nodes will need access to this port.
- Lastly we have the nodePort service. This service exposes our services and ports on each individual node in our cluster on the port range of 30000 through 32767. Anything would need access to the services published on these ports should be opened. Could you say that it exposes the container runtime? Nope, it is the service of the container runtime that is exposed.
