# Working with Your Kubernetes Cluster

## Using `kubectl` to Interact with Your Cluster

kubectl is the primary CLI tool to control workloads in your kubernetes cluster. We use kubectl to perform operations against our cluster. Basically we can run most any CRUD operation on any kind of resource in kubernetes. We will want to run operations on resources.

- Operations - what you want to do.
    - create, read, update, delete
- Resources - what you want to do it to.
    - pods, deployment, services, etc.
- Output - if you are looking for output, you can define the format 

### Operations
Core operations:
- apply/create - create resources
- run - start a pod from an image
- explain - gives documentation of API resources; very valuable in CLI
- delete - delete resurces.
- get - display basic information about resources/object
- describle - detailed resource information; good for trouble shooting
- exec - execute a command on a container
- logs - view logs on a container

https://kubernetes.io/docs/reference/kubectl/overview/#operations

### Resources - what do you want to do it to?

Resources like nodes, pods, services and many more.

### Output

Can specify kubetcl output format
- wide - additinal information
- yaml - yaml formatted api object
- json - json formatted api object
- dry-run - just outputs yaml for an object without sending it to API -> etcd -> scheduler -> kubectl

### How do we use this all?

As a general overview:

```text
kubectl [command] [type] [name] [flags]
kubectl get       pods    pod1  --output=yaml
kubectl create deployment nginx --image=ngix
```

Example Commands

```
Display Resource in Our Cluster
kubectl cluster-info
kubectl get nodes
kubectl get nodes -o wide
kubectl get pods
kubectl get pods --namespace kube-system
kubectl get pods --namespace kube-system -o wide
kubectl get all --all-namespaces | less
kubectl api-resources | less
kubectl explain pod | less - look at the object pod
kubectl explain pod.spec | less - get more detail about the spec in pod
kubectl explain pod.spec.containers | less - even deeper dive into information
kubectl explain pod --recursive | less - The most data available? 
    - This reminds me of what I use for details for yaml pipelines and gh actions.
    - Use this when trying to build out a yaml file and I need details on what does what.

kubectl describe nodes c1-cp1 | less
    - give a ton of information regarding the object
    - can get info about different objects

kubectl -h | less
kubectl get -h | less
kubectl create -h | less

```


## Application Deployments

### Imperative

- Generally this is executing commands at the command line, one at a time.
- Giving explicit instructions on what I want done.
- Scope is usually one object at a time per command.

`kubectl create deployment nginx --image=nginx`

`kubectl run nginx --image=nginx`

As your system/cluster gets more complex, this way of managing your cluster will be come tedious. This is where declareative deployments come in.

### Declariative

Declaritive means we define our desired state in code. We declare what we want the system to look like, in code, and then kubernetes gets to work to make it so.

- Manifests are where we can describe configurations in code.
- `kubectl apply -f deployment.yaml`

#### Basic Manifest

Manifests can be created by for many different types of API ojbects in kubernetes. We'll focus on a deployment manifest for our 

- `apiVersion` is the first thing will find on all manifests
    - `apiVersion: apps/v1`
    - since we are using a deployment, the value will be "apps/v1" Q: I wonder why this is?
    - As the kubernetes api develops and changes, the versioning of the apiVersion is important.
        - this is so you know you can expect a certain type of behavior depnding on the version used.
        - we do not want to introduce breaking changes because of a new API version is being used.
        - this adds stability to the objects defined in our manifests.
- `kind` is the next thing we will find in a manifest
    - `kind: Deployment`
    - You can thing of this as the "kind" of object we want to define
    - `kubectl api-resources` will list all the resources available 
        - these are the objects that will be listed there
- `metadata` is next and this is where we describe our deployment        
    - we'll just give it a `name: hello-world`
- `spec` is next and this defines the **implementation details** of the deployment objec.
    - we can define the number of `replicas: 2` aka number of pods to run
- `selector` is the way for a deployment to know which pods are a member of this deployment
- `template` is used to define the pods created by this deployment
    - this is also known as the **pod template**
    - it will have another metadata section with some labels
    - these labels are matched with the deployment spec.selector above
    - these lables are assigned to each pod created by this deployment
    - this is how the deployment is able to track which pods are a member of this deployment 
- `spec` lastly there is one more spec; more like `template.spec`
    - this is where we will define the containers, started by the pods, in the deployment
    - use the location of an image
    - give the container a name

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadta:
  name: hello-world
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-world
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
      - image: gcr.io/google-samples/hello-app:1.0
        name: hello-app
```

To get this deployed we can use kubectl; `kubectl apply -f deployment.yaml`. Make sure you have a file named, deployment.yaml, with this yaml inside.

- The file will get read by the API server and then watch the magic happen.
- NOTE: `kubectl explain (OBJECT)` is awesome for when you are building a declaritve object file.
    - however, you don't want to be typing this by hand.
    - can use `dry-run` create basic manifests like the one above.

#### Generating Manifests with `dry-run`

As mentioned before we can write manifests by hand although sometimes you may not get the spacing right and the fields in the right place. You can generate the yaml to create really any API object in kubernetes.

```bash
kubectl create deployment hello-world \
    --image=gcr.io/google-samples/hello-app:1.0 \
    --dry-run=client -o yaml > deployment.yml
```

The output is:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: hello-world
  name: hello-world
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello-world
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: hello-world
    spec:
      containers:
      - image: gcr.io/google-samples/hello-app:1.0
        name: hello-app
        resources: {}
Status: {}
```
