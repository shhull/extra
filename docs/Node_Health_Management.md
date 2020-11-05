# Managing Node Health

A node provides the runtime environments for containers. Each node in a Kubernetes cluster has the required services to be managed by the master. Nodes also have the required services to run pods, including the container runtime, a kubelet, and a service proxy.

OpenShift Container Platform creates nodes from a cloud provider, physical systems, or virtual systems. Kubernetes interacts with node objects that are a representation of those nodes. The master uses the information from node objects to validate nodes with health checks. A node is ignored until it passes the health checks, and the master continues checking nodes until they are valid.
We can manage nodes in our instance using the CLI. When we perform node management operations, the CLI interacts with node objects that are representations of actual node hosts. The master uses the information from node objects to validate nodes with health checks.

You can review cluster node health status, resource consumption statistics, and node logs using the below commands. Additionally, you can query kubelet status on individual nodes.


## 1. Node reporting NotReady
***

The mentioned problem was seen on 4.5.4 running on KVM/libvirt, but this could happen and be applied on other platforms.    

Some nodes in this 3-master/5-worker cluster start showing "NotReady" state with "Kubelet stopped posting node status" in `oc describe node` output.

SSH'ing into those "NotReady" nodes, it could be seen that `Current certificate is expired` in `journalctl -u kubelet`, and that is precisely the issue preventing communication with API server.

You might also see:

```text
Failed Units: 1
  NetworkManager-wait-online.service
[core@worker-0 ~]$
```
upon SSH login, but that is a red herring. 
  

In order to resolve this issue run the following commands on "NotReady" node(s):  

$ `sudo systemctl restart kubelet`  

followed by, anywhere you can run `oc` commands against the cluster;  

$ `oc get csr | grep Pending | awk '{print $1}' | xargs oc adm certificate approve`  


Note - Make sure you have no more "Pending" CSRs after a minute or two as well.

   

## 2. Querying the kubelet’s status on a node
***



The kubelet is managed using a systemd service on each node. Review the kubelet’s status by querying the kubelet systemd service within a debug Pod.

a. Start a debug Pod for a node: $ `oc debug node/node_name`

b.  Set /host as the root directory within the debug shell. The debug Pod mounts the host’s root file system in /host within the Pod. By changing the root directory to /host, you can run binaries contained in the host’s executable paths: # `chroot /host`

c.  Check whether the kubelet systemd service is active on the node: # `systemctl is-active kubelet`

d. Output a more detailed kubelet.service status summary: # `systemctl status kubelet`


**_Status on CLI_**
```text
oc debug node/master0.ocp-support-suad.cp.fyre.ibm.com
Starting pod/master0ocp-support-suadcpfyreibmcom-debug ...
To use host binaries, run `chroot /host`
Pod IP: 10.17.73.96
If you don't see a command prompt, try pressing enter.
sh-4.2# chroot /host
sh-4.4# systemctl is-active kubelet
active
sh-4.4# systemctl status kubelet
● kubelet.service - MCO environment configuration
Loaded: loaded (/etc/systemd/system/kubelet.service; enabled; vendor preset: enabled)
Drop-In: /etc/systemd/system/kubelet.service.d
└─10-mco-default-env.conf
Active: active (running) since Thu 2020-08-27 07:47:12 UTC; 1 day 3h ago
Process: 1347 ExecStartPre=/bin/rm -f /var/lib/kubelet/cpu_manager_state (code=exited, status=0/SUCCESS)
Process: 1344 ExecStartPre=/bin/mkdir --parents /etc/kubernetes/manifests (code=exited, status=0/SUCCESS)
Main PID: 1349 (kubelet)
Tasks: 38 (limit: 51304)
Memory: 264.3M
CPU: 7h 15min 31.395s
CGroup: /system.slice/kubelet.service
└─1349 kubelet --config=/etc/kubernetes/kubelet.conf --bootstrap-kubeconfig=/etc/kubernetes/kubeconfig --kubeconfig=/var/lib/kubelet/kubeconfig --container-runtime=remote --container-runtime-en>


Aug 28 11:35:41 master0.ocp-support-suad.cp.fyre.ibm.com hyperkube[1349]: I0828 11:35:41.827568 1349 atomic_writer.go:157] pod openshift-kube-scheduler-operator/openshift-kube-scheduler-operator-769d7b>
Aug 28 11:35:41 master0.ocp-support-suad.cp.fyre.ibm.com hyperkube[1349]: I0828 11:35:41.827609 1349 operation_generator.go:657] MountVolume.SetUp succeeded for volume "config" (UniqueName: "kubernetes>
Aug 28 11:35:41 master0.ocp-support-suad.cp.fyre.ibm.com hyperkube[1349]: I0828 11:35:41.827720 1349 secret.go:183] Setting up volume node-ca-token-r9zm6 for pod 42e3fbda-1361-4c75-9f72-7938a75a6073 at>
Aug 28 11:35:41 master0.ocp-support-suad.cp.fyre.ibm.com hyperkube[1349]: I0828 11:35:41.827792 1349 secret.go:207] Received secret openshift-image-registry/node-ca-token-r9zm6 containing (4) pieces of>
Aug 28 11:35:41 master0.ocp-support-suad.cp.fyre.ibm.com hyperkube[1349]: I0828 11:35:41.828220 1349 atomic_writer.go:157] pod openshift-image-registry/node-ca-vhm68 volume node-ca-token-r9zm6: no upda>
Aug 28 11:35:41 master0.ocp-support-suad.cp.fyre.ibm.com hyperkube[1349]: I0828 11:35:41.828265 1349 operation_generator.go:657] MountVolume.SetUp succeeded for volume "node-ca-token-r9zm6" (UniqueName>
Aug 28 11:35:41 master0.ocp-support-suad.cp.fyre.ibm.com hyperkube[1349]: I0828 11:35:41.828357 1349 secret.go:183] Setting up volume serving-cert for pod a3679c68-645c-4b58-9324-b03a923624f0 at /var/l>
Aug 28 11:35:41 master0.ocp-support-suad.cp.fyre.ibm.com hyperkube[1349]: I0828 11:35:41.828419 1349 secret.go:207] Received secret openshift-kube-scheduler-operator/kube-scheduler-operator-serving-cer>
Aug 28 11:35:41 master0.ocp-support-suad.cp.fyre.ibm.com hyperkube[1349]: I0828 11:35:41.828681 1349 atomic_writer.go:157] pod openshift-kube-scheduler-operator/openshift-kube-scheduler-operator-769d7b>
Aug 28 11:35:41 master0.ocp-support-suad.cp.fyre.ibm.com hyperkube[1349]: I0828 11:35:41.828717 1349 operation_generator.go:657] MountVolume.SetUp succeeded for volume "serving-cert" (UniqueName: "kube>
Aug 28 11:35:41 master0.ocp-support-suad.cp.fyre.ibm.com hyperkube[1349]: I0828 11:35:41.837829 1349 atomic_writer.go:157] pod openshift-image-registry/node-ca-vhm68 volume serviceca: no update require>
Aug 28 11:35:41 master0.ocp-support-suad.cp.fyre.ibm.com hyperkube[1349]: I0828 11:35:41.837926 1349 operation_generator.go:657] MountVolume.SetUp succeeded for volume "serviceca" (UniqueName: "kuberne>
Aug 28 11:35:41 master0.ocp-support-suad.cp.fyre.ibm.com hyperkube[1349]: I0828 11:35:41.970203 1349 exec.go:60] Exec probe response: ""
Aug 28 11:35:41 master0.ocp-support-suad.cp.fyre.ibm.com hyperkube[1349]: I0828 11:35:41.970272 1349 prober.go:133] Liveness probe for "ovs-p2qkz_openshift-sdn(6d62e5db-053b-4573-95ce-d7d478f578d9):ope>

```

## 3. Node-logs: Get logs for NetworkManager

***

The below command will give the logs of the network manager of a particular node of a cluster.

                
  $ `oc adm node-logs --role master -u NetworkManager.service`



```text
Sep 06 04:01:37.044137 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0439] dhcp4 (enp0s3): option dhcp_lease_time      => '600'
Sep 06 04:01:37.044177 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0441] dhcp4 (enp0s3): option domain_name          => 'cp.fyre.ibm.com'
Sep 06 04:01:37.044199 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0441] dhcp4 (enp0s3): option domain_name_servers  => '10.17.64.21 10.17.64.22'
Sep 06 04:01:37.044219 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0442] dhcp4 (enp0s3): option domain_search        => 'cp.fyre.ibm.com'
Sep 06 04:01:37.044239 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0442] dhcp4 (enp0s3): option expiry               => '1599365497'
Sep 06 04:01:37.044259 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0442] dhcp4 (enp0s3): option ip_address           => '10.17.73.158'
Sep 06 04:01:37.044280 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0442] dhcp4 (enp0s3): option next_server          => '10.17.64.9'
Sep 06 04:01:37.044301 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0442] dhcp4 (enp0s3): option requested_broadcast_address => '1'
Sep 06 04:01:37.044322 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0443] dhcp4 (enp0s3): option requested_domain_name => '1'
Sep 06 04:01:37.044342 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0443] dhcp4 (enp0s3): option requested_domain_name_servers => '1'
Sep 06 04:01:37.044363 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0443] dhcp4 (enp0s3): option requested_domain_search => '1'
Sep 06 04:01:37.044383 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0443] dhcp4 (enp0s3): option requested_host_name  => '1'
Sep 06 04:01:37.044403 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0443] dhcp4 (enp0s3): option requested_interface_mtu => '1'
Sep 06 04:01:37.044424 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0444] dhcp4 (enp0s3): option requested_ms_classless_static_routes => '1'
Sep 06 04:01:37.044471 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0444] dhcp4 (enp0s3): option requested_nis_domain => '1'
Sep 06 04:01:37.044491 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0444] dhcp4 (enp0s3): option requested_nis_servers => '1'
Sep 06 04:01:37.044511 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0444] dhcp4 (enp0s3): option requested_ntp_servers => '1'
Sep 06 04:01:37.044532 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0445] dhcp4 (enp0s3): option requested_rfc3442_classless_static_routes => '1'
Sep 06 04:01:37.044552 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0445] dhcp4 (enp0s3): option requested_root_path  => '1'
Sep 06 04:01:37.044572 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0445] dhcp4 (enp0s3): option requested_routers    => '1'
Sep 06 04:01:37.044593 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0445] dhcp4 (enp0s3): option requested_static_routes => '1'
Sep 06 04:01:37.044613 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0445] dhcp4 (enp0s3): option requested_subnet_mask => '1'
Sep 06 04:01:37.044637 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0446] dhcp4 (enp0s3): option requested_time_offset => '1'
Sep 06 04:01:37.044658 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0446] dhcp4 (enp0s3): option requested_wpad       => '1'
Sep 06 04:01:37.044734 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0446] dhcp4 (enp0s3): option routers              => '10.17.64.1'
Sep 06 04:01:37.044759 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0447] dhcp4 (enp0s3): option subnet_mask          => '255.255.224.0'
Sep 06 04:01:37.044779 master2.ocp-support-suad.cp.fyre.ibm.com NetworkManager[1163]: <info>  [1599364897.0447] dhcp4 (enp0s3): state changed extended -> extended
```


## 4. Nodes report ready but ETCD health check fails
***


```text
[root@master02 ~]#  etcdctl -C https://master00.ose.example.com:2379,https://master01.ose.example.com:2379,https://master01.ose.example.com:2379 --ca-file=/etc/origin/master/master.etcd-ca.crt     --cert-file=/etc/origin/master/master.etcd-client.crt     --key-file=/etc/origin/master/master.etcd-client.key cluster-health
member e0e2c123213680f is healthy: got healthy result from https://192.168.200.50:2379
member 64f1077d838e039c is healthy: got healthy result from https://192.168.200.51:2379
member a9e031ea9ce2a521 is unhealthy: got unhealthy result from https://192.168.200.52:2379
```

In the event that the health check fails check the status of etcd you could see one or a combination of the following:

```text
[root@master02 ~]#  etcdctl -C https://master00.ose.example.com:2379,https://master01.ose.example.com:2379,https://master01.ose.example.com:2379 --ca-file=/etc/origin/master/master.etcd-ca.crt     --cert-file=/etc/origin/master/master.etcd-client.crt     --key-file=/etc/origin/master/master.etcd-client.key cluster-health
member e0e2c123213680f is healthy: got healthy result from https://192.168.200.50:2379
member 64f1077d838e039c is healthy: got healthy result from https://192.168.200.51:2379
member a9e031ea9ce2a521 is unhealthy: got unhealthy result from https://192.168.200.52:2379
[root@master01 ~]# systemctl status etcd
● etcd.service - Etcd Server
   Loaded: loaded (/usr/lib/systemd/system/etcd.service; enabled; vendor preset: disabled)
   Active: active (running) since Thu 2016-02-25 08:43:37 CST; 4h 32min ago
 Main PID: 1103 (etcd)
   CGroup: /system.slice/etcd.service
           └─1103 /usr/bin/etcd --name=master01.ose.example.com --data-dir=/var/lib/etcd/ --lis...


Feb 25 11:32:52 master01 etcd[1103]: got unexpected response error (etcdserver: request timed out)
Feb 25 11:32:52 master01 etcd[1103]: got unexpected response error (etcdserver: request timed out)
Feb 25 11:33:02 master01 etcd[1103]: got unexpected response error (etcdserver: request timed out)
Feb 25 11:33:02 master01 etcd[1103]: got unexpected response error (etcdserver: request timed out)
Feb 25 11:33:12 master01 etcd[1103]: got unexpected response error (etcdserver: request timed out)
Feb 25 11:33:12 master01 etcd[1103]: got unexpected response error (etcdserver: request timed out)
[root@master00 ~]# systemctl status etcd
● etcd.service - Etcd Server
   Loaded: loaded (/usr/lib/systemd/system/etcd.service; enabled; vendor preset: disabled)
   Active: active (running) since Thu 2016-02-25 08:43:55 CST; 4h 32min ago
 Main PID: 1097 (etcd)
   CGroup: /system.slice/etcd.service
           └─1097 /usr/bin/etcd --name=master00.ose.example.com --data-dir=/var/lib/etcd/ --lis...


Feb 25 11:40:25 master00 etcd[1097]: the connection to peer a9e031ea9ce2a521 is unhealthy
Feb 25 11:40:55 master00 etcd[1097]: the connection to peer a9e031ea9ce2a521 is unhealthy
Feb 25 11:41:25 master00 etcd[1097]: the connection to peer a9e031ea9ce2a521 is unhealthy
Feb 25 11:41:55 master00 etcd[1097]: the connection to peer a9e031ea9ce2a521 is unhealthy
Feb 25 11:42:25 master00 etcd[1097]: the connection to peer a9e031ea9ce2a521 is unhealthy
```

**Solution**

In most cases restarting etcd one at a time on each etcd host resolves the issue

 $ `sudo systemctl restart etcd`

Reference Link - <http://v1.uncontained.io/playbooks/troubleshooting/troubleshooting_guide.html>


## 5. File System tracking(a complete monitoring for disk usage)
***

To monitor filesystems and more precisely the overall space remaining on various filesystems , 
the node exporter exports two metrics to retrieve such statistics :

a. `node_filesystem_avail_bytes `  
b. `node_filesystem_size_bytes`  

Use below query in Prometheus for the overall filesystem usage by device or by mountpoint :

`( 1 - node_filesystem_avail_bytes /node_filesystem_size_bytes )*100`


## 6. Read & Write Latencies
***

Another great metric for monitoring is the read and write latencies on our disks.
The node exporter exports multiple metrics to compute it.
On the read side, we have:

a.`node_disk_read_time_seconds_total`    
b.`node_disk_reads_completed_total`  


On the write side, we have:

a.`node_disk_write_time_seconds_total`   
b.`node_disk_writes_completed_total`  


If we compute rates for the two metrics, and divide one by the other, we are able to compute the latency or the time that your disk takes in order to complete such operations.
Use below query in Prometheus for the disk latency :
 `rate(node_disk_write_time_seconds_total[5s])/rate(node_disk_writes_completed_total[5s])*100`

