# Troubleshoot Security Context Constraints (SCC)

This document contains information regarding troubleshooting SCC related issues. 
Document includes the initial diagnosis step which helps find the actual error.
To solve the SCC related issues, you need a basic understanding of the SCC, and we will explain what SCC is along with its role in the cluster. 

## Initial Diagnosis:

* $ `oc describe pod <pod-name> | grep scc`
    This command show type of SCC used in the pod deployment. 
    Knowing  SCC name will let us know about control permissions for a pod. 
    These permissions include actions that a pod, a collection of containers, can perform, and what resources it can access.  

* $ `oc describe scc <scc-name>`
    Examine the pod SCC using the above command. 
    The command output consists of permissions include actions that a pod, a collection of containers, can perform, and what resources it can access.


### Sample Issue :
The pod was unable to mount the host volume due to user doesn't have right permissions.
The error is pasted below. 

Error:

```text

  | CAUSE: current user doesn't have permissions for writing to /var/lib/mongodb/data directory
  | DETAILS: current user id = 184, user groups: 997 0
  | DETAILS: directory permissions: drwxrwsr-x owned by 0:1000360000, SELinux: system_u:object_r:svirt_sandbox_file_t:s0:c9,c19
```
Solution:   
Allowing access to SCCs with a RunAsAny FSGroup strategy can prevent users from accessing their block devices. 
Pods need to specify a fsGroup in order to take over their block devices. 
Normally, this is done when the SCC FSGroup strategy is set to MustRunAs. 
If a user’s pod is assigned an SCC with a RunAsAny FSGroup strategy, then the user may face permission denied errors until they discover that they need to specify a fsGroup themselves.
To solve the error first need to find out the scc type used by the pod then edit the SCC according to your pod requirement or change the SCC type.
Editing the current SCC and add FSGroup to MustRunAs  

$ `oc edit scc <scc-name>`  
Edit the SCC using this command. 
You can edit SCC to define a set of conditions that a pod must run with in order to be accepted into the system.  
FSGroup Strategy: RunAsAny


## What is SCC?

SCC is basically used for pod restriction, which means it defines the limitations for a pod, as in what actions it can perform and what all things it can access in the cluster.

Advantages of using SCC.

* Host directories can be used as volumes.
* Able can set conditions for container user ID and Selinux Context of the container.
* Able to run containers as privileged.
* Able to control the use of host namespaces and networking.
* Able to control usage of volume types.
* Able to control capabilities that a container can request.
* FSGroup can be allocated to pod volumes.

OpenShift provides a set of predefined SCC that can be used, modified, and extended by the administrator.

```text  
$ oc get scc 
NAME              PRIV   CAPS  HOSTDIR  SELINUX    RUNASUSER         FSGROUP   SUPGROUP  PRIORITY
anyuid            false   []   false    MustRunAs  RunAsAny          RunAsAny  RunAsAny  
hostaccess        false   []   true     MustRunAs  MustRunAsRange    RunAsAny  RunAsAny  
hostmount-anyuid  false   []   true     MustRunAs  RunAsAny          RunAsAny  RunAsAny
nonroot           false   []   false    MustRunAs  MustRunAsNonRoot  RunAsAny  RunAsAny 
privileged        true    []   true     RunAsAny   RunAsAny          RunAsAny  RunAsAny
restricted        false   []   false    MustRunAs  MustRunAsRange    RunAsAny  RunAsAny
```
If one wishes to use any pre-defined scc, that can be done by simply adding the user or the group to the scc group.

$ `oadm policy add-user-to-scc <scc_name> <user_name>`

$ `oadm policy add-group-to-scc <scc_name> <group_name>`

OpenShift guarantees that the capabilities required by a container are granted to the user that executes the container at admission time.  We can not allow any container to get access to unnecessary capabilities or to run in an insecure way (e.g. privileged or as root)

Adding a regular user or to a group given access to the SCC allows them to run privileged pods. There are mainly four section in SCC to control access to volumes in OpenShift.

1. Supplemental Groups
1. fsGroup
1. runAsUser
1. seLinuxOptions

### 1. Supplemental Groups
Supplemental groups are regular Linux groups. 
When a process runs in the system, it runs with a user ID and group ID. 
These groups are used for controlling access to shared storage.

* Check the NFS mount using the following command.
 
```
   # showmount -e <nfs-server-ip-or-hostname>
   Export list for f21-nfs.vm: 
   /opt/nfs * 
```

* Check NFS details on the mount server using the following command.
   
```  
   # cat /etc/exports 
   /opt/nfs *(rw,sync,no_root_squash)
```

* Check owner of exported directory
   
```
   $ ls -lZ /opt/nfs -d
   drwxrws---. nfsnobody 2325 unconfined_u:object_r:usr_t:s0 /opt/nfs
```

```
   $ id nfsnobody
   uid = 65534(nfsnobody) gid = 454265(nfsnobody) groups = 454265(nfsnobody)
```

The `/opt/nfs/` export is accessible by UID 454265 and the group 2325.     

    ```
    apiVersion: v1
    kind: Pod
    ...
    spec:
       containers:
       - name: ...
          volumeMounts:
          - name: nfs
             mountPath: /usr/share/...
       securityContext:
          supplementalGroups: [2325]
       volumes:
       - name: nfs
          nfs:
          server: <nfs_server_ip_or_host>
          path: /opt/nfs
    ```

### 2. fsGroup

fsGroup stands for the file system group which is used for adding container supplemental groups. 
Supplement group ID is used for shared storage and fsGroup is used for block storage.

```text
kind: Pod
spec:
   containers:
   - name: ...
   securityContext:
      fsGroup: 2325
```

### 3. runAsUser

runAsUser uses the user ID for communication. 
This is used in defining the container image in pod definition. A single ID user can be used in all containers, if required.
While running the container, the defined ID is matched with the owner ID on the export. 
If the specified ID is defined outside, then it becomes global to all the containers in the pod. 
If it is defined with a specific pod, then it becomes specific to a single container.

```text
spec:
   containers:
   - name: ...
      securityContext:
         runAsUser: 454265
```

### 4. seLinuxOptions

SELinux default when not defined in the pod definition or in the SCC. 
Level can be defined globally for the entire pod, or individually for each container.
SElinux values, policies and values given below

values: 1.Enforcing 2.permissive 3.disabled

policies:1.targeted 2.minimum 3.mls(multilevel)

components:

1. Selinux user
1. Selinux role
1. Type
1. Sensitivity / category

```text
spec:
  container:
     seLinuxContext: 
        type: MustRunAs
        SELinuxOptions: 
           user: <selinux-user-name>
           role: ...
           type: ...
           level: ...
```




