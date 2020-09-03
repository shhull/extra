Collection of issues we faced and external pages/links that actually helped resolve them;

## 2020-09

* 4.5 on libvirt, `authentication` and `console` operators not available, and `console` pod's log indicating DNS issue for "oauth-openshift.<domain>"  
  => <https://github.com/openshift/installer/issues/1648#issuecomment-585235423>
  
## 2020-08

* node `NotReady` after reboot perhaps after shut down for a few days, with "Kubelet stopped posting node status" in `oc describe node`  
  essentially, `sudo systemctl restart kubelet` on the bad node, followed by `oc get csr | grep Pending | awk '{print $1}' | xargs oc adm certificate approve`, perhaps multiple times as a few CSRs could come in for approval sequentially.  
  => <https://docs.openshift.com/container-platform/4.1/backup_and_restore/disaster_recovery/scenario-3-expired-certs.html>
  
* random intermittent API server errors like "connection refused," "authentication required," "internal error," with `etcd` running on slow disk  
  => <https://github.com/openshift/release/blob/23074b5/ci-operator/templates/openshift/installer/cluster-launch-installer-openstack-e2e.yaml#L375-L382>

##### (2020-07-30 4.5 GA)

##### (2020-06-23 4.4 GA)

## 2020-06

* `OOMKilled` on _large_ POWER system, while same set of pods run fine on _smaller_ x86 system, with possible tinkering with `slub_max_order` kernel param  
  => <https://medium.com/ibm-cloud/fortifying-ibm-cloud-private-for-large-enterprise-power-systems-6119804f0103>

##### (2020-04-30 4.3 GA)

## 2020-02

* 4.x image registry not accessible externally by default, need `default-route` created  
  => <https://docs.openshift.com/container-platform/4.3/registry/securing-exposing-registry.html>  
  => <https://docs.openshift.com/container-platform/4.4/registry/configuring-registry-operator.html#registry-operator-default-crd_configuring-registry-operator>