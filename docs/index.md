# Welcome to OpenShift on IBM Power Extras!

## Utility Scripts

* `ocp-upgrade-paths.sh` - lists available OCP upgrade paths
* `setup_nfs_provisioner.sh` - sets up a NFS share on the system, exports it, installs NFS provisioner pod to support dynamically provision PVs on NFS

## KnowledgeBase

* [How to troubleshoot Pending Pods](h2t-pending-pods)
* [How to troubleshoot Resource Exhaustion situation](h2t-resource-exhaustion)
* [How to troubleshoot Security Context (SCC) issues](h2t-scc)
* and more to come!

---

## Commands for working on docs locally

1. Fork https://github.com/ocp-power-automation/extra.git perhaps naming your fork "power-automation-extra" as an example
1. `git clone https://github.com/<yourid>/power-automation-extra.git`
1. `cd power-automation-extra`
1. `pip install mkdocs`
1. `mkdocs serve` - this will start the live-reloading docs server on port 8000, ctrl-c to stop
1. edit docs under the `./docs` subdir with your favorite editor (1 sentence per line)
1. point your browser to http://localhost:8000
1. repeat the edit & check until you are happy
1. `git add` your changes
1. `git commit -s` with good comment
1. `git push` to your forked repo
1. Create a PR against upstream `master` branch

For full documentation, visit [git-scm.com](https://git-scm.com/docs), [mkdocs.org](https://www.mkdocs.org).