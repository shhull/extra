# PowerVS Frequently Asked Questions

---
## When Building out a Cluster

#### VM Console shows "grub>"
Not the end of the world. Just type `normal` and hit ENTER.

#### VM Console shows "grub rescue>"
GRUB 2 was unable to find the grub folder or its contents are missing/corrupted. The grub folder contains the GRUB 2 menu, modules and stored environmental data. This should not happen very often. Simply reboot the VM from <https://cloud.ibm.com>.

#### RHCOS Ignition stalls with "version mismatch"
The version of RHCOS you are booting up with on cluster nodes cannot handle what the OCP build/version is serving as config for cluster nodes. Make sure they match at least the major and minor versions (eg. 4.5) in your `var.tfvars` file.

---
## Problems on a Running Cluster

#### Need to add more CPU/Memory to Node
Go to <https://cloud.ibm.com>, then to your PowerVS service instance, find your VM that backs the cluster Node (eg. myocp-worker-0), click to open up the details page, then "Edit details," update the CPU/Memory with new values, and Save. You should get "Edit successful" message, and your OCP cluster should recognize the change and start showing in Compute section of Web Console. If something fails along the way, try "OS Shutdown" action, edit CPU/Memory as necessary while in "Shutoff" state, and restart the VM.

---
## Securing a Cluster

#### TBA