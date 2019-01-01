# microk8s (Micro-Kubernetes)

    # Get status
    microk8s.status

    # Start 
    microk8s.start

### Current status and issues

* I was able to access pgadmin via `port-forward`, but not through the service, even though it is running.
* I was not able to access the pomodoro-pgsql via pgadmin yet. 
* I was able to do a `dig SRV pomodoro-pgsql.pomodoro-services.svc.cluster.local`. See bottom of this page.
* pgadmin is extremely slow

Here is an error message from pgadmin. This tells me that it can find the ip of the pod, but cannot connect. Why?

    Unable to connect to server:

    could not connect to server: Operation timed out
    Is the server running on host "pomodoro-pgsql-0.pomodoro-pgsql.pomodoro-services.svc.cluster.local" (10.1.1.191) and accepting
    TCP/IP connections on port 5432?

Here are the logs from pomodoro-pgsql-0 via `k8p logs pomodoro-pgsql-0`

    2019-01-01 16:16:09.952 UTC [1] LOG:  listening on IPv4 address "0.0.0.0", port 5432
    2019-01-01 16:16:09.952 UTC [1] LOG:  listening on IPv6 address "::", port 5432
    2019-01-01 16:16:10.180 UTC [1] LOG:  listening on Unix socket "/var/run/postgresql/.s.PGSQL.5432"
    2019-01-01 16:16:10.635 UTC [20] LOG:  database system was shut down at 2019-01-01 10:08:13 UTC
    2019-01-01 16:16:10.810 UTC [1] LOG:  database system is ready to accept connections


## Informational
  
microk8s snap is readonly. This means that I cannot change the default namespace with:

    sudo microk8s.kubectl config set-context microk8s --namespace pomodoro-services

### Needs

* Container with utilities in the registry (curl, ping, dns tools, etc.)

## Examples

    # Get pods (in default namespace)
    microk8s.kubectl get pods

    # Launch a pod (from Kubernetes directory)
    microk8s.kubectl create -f pomodoro-ping-rapi-pod.yaml

    # Delete a pod 
    microk8s.kubectl delete pods pomodoro-ping-rapi

    # Reviewing the pod
    microk8s.kubectl get pods pomodoro-ping-rapi -o yaml | less

    # Reviewing the logs (if only container) (use `-c <container name>` for more containers)
    microk8s.kubectl logs pomodoro-ping-rapi

    # forward the port for exploration. 
    # You can then view this in the browser at http://localhost:8888/api/ping
    microk8s.kubectl port-forward pomodoro-ping-rapi 8888:80

    # Get pods with labels, filter on environment
    microk8s.kubectl get pods -L env -l env=development

## Namespaces
    microk8s.kubectl create -f pomodoro-ns.yaml

    microk8s.kubectl get pods --namespace pomodoro-services

    microk8s.kubectl delete pods --all --namespace pomodoro-services

## ReplicaSet

    # Launch a ReplicaSet
    microk8s.kubectl create -f pomodoro-ping-rapi-rs.yaml



## Service examples

    # chapter 2 of Kubernetes in action
    kubectl expose rc kubia --type=LoadBalancer --name kubia-http    

    microk8s.kubectl `
        --namespace pomodoro-services `
        exec -it pomodoro-utils `
        -- curl -s http://pomodoro-ping-rapi:8888/api/ping
        

    microk8s.kubectl `
        --namespace pomodoro-services `
        exec -it pomodoro-utils `
        -- /bin/bash

## Try this

    microk8s.kubectl run `
        --namespace pomodoro-services `
        -it srvlookup `
        --image=tutum/dnsutils --rm `
        --restart=Never `
        -- dig SRV pomodoro-pgsql.pomodoro-services.svc.cluster.local

    microk8s.kubectl run `
        --namespace pomodoro-services `
        -it srvlookup `
        --image=localhost:32000/pomodoro-utils --rm `
        --restart=Never `
        -- dig SRV pomodoro-pgsql.pomodoro-services.svc.cluster.local

    microk8s.kubectl run `
        --namespace pomodoro-services `
        -it srvlookup `
        --image=localhost:32000/pomodoro-utils --rm `
        --restart=Never `
        -- /bin/bash
