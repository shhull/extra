# How to Troubleshoot Pending Pods

A pod stuck in pending state cannot be scheduled onto a node until the problem is identified and resolved.
It could be caused due to a handful of reasons ranging from resource issues to the rules applied to the pods and nodes.
For this, a few commands could be executed to narrow down the possibilities and focus on what could have been the exact issue causing it.
A few initial diagnostic commands mentioned below could be a starting step to help troubleshoot the pods stuck in pending state.

## Initial diagnosis:

* `oc adm top nodes`  
This command will show how CPU and Memory are tight across nodes in the cluster.
If you see high percentage number(s), the node(s) is/are running out of that resource, and possibly preventing new pods from being scheduled and starting.
Check reason 1 below.
* `oc describe node node-name`  
This is a good follow-up command to above, and will provide detailed information of a specific node. Checking the information under 'Allocated resources' or 'Conditions' could help in understanding if the problem is inclining towards insufficient resources(memory or CPU) on the node and in determining the resources to be allocated to the pod accordingly
* `oc get pods -A | grep Pending`  
This command will show pods that are in Pending state in the cluster.
If you see only a handful, you are in luck and proceed with below oc describe pod command for those to find out more details and which subsection of this document to go.
If you see many more Pending pods, it may be quicker to suspect more systemic issues, than individual pod issues, although it may still come down to it.
* `oc describe pod pod-name`  
The 'Events' section of the output would provide the current status of the pod and also the reason for it being in that state.
If it is stuck in pending state, based on the reason, that particular issue can be resolved by following the steps below

## 1. Reason: Insufficient resources on the nodes available

TBD...