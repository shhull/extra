#!/bin/bash
# $1=OCP 4.x version for which to list available upgrade paths eg. 4.5

function ocp-upgrade-paths() {
  version=$1
  for channel in stable fast candidate ; do
      echo "====== $channel-$version ======"
      curl -sH 'Accept: application/json' "https://api.openshift.com/api/upgrades_info/v1/graph?channel=$channel-$version" | jq -r '[.nodes[].version] | sort | unique[]'
  done
}

ocp-upgrade-paths $1

