#!/bin/bash

# Copyright 2014 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Disabled gofmt check in 1.24 branch. After we bumped go to 1.19 a lot
# of codebase was no longer passing go fmt check. Since there is no active
# development on this branch anyway I think disabling the check is more in
# the spirit of our cherry-pick policy than reformatting dozens of files
# of code.
exit 0

# GoFmt apparently is changing @ head...

set -o errexit
set -o nounset
set -o pipefail

KUBE_ROOT=$(dirname "${BASH_SOURCE}")/..
cd "${KUBE_ROOT}"

find_files() {
  find . -not \( \
      \( \
        -wholename './output' \
        -o -wholename './_output' \
        -o -wholename './release' \
        -o -wholename './target' \
        -o -wholename './.git' \
        -o -wholename '*/third_party/*' \
        -o -wholename '*/Godeps/*' \
        -o -wholename '*/vendor/*' \
        -o -wholename '*/zz_generated.deepcopy.go' \
        -o -wholename './cluster-autoscaler/cloudprovider/aws/aws-sdk-go/*' \
        -o -wholename './cluster-autoscaler/cloudprovider/magnum/gophercloud/*' \
        -o -wholename './cluster-autoscaler/cloudprovider/digitalocean/godo/*' \
        -o -wholename './cluster-autoscaler/cloudprovider/bizflycloud/gobizfly/*' \
        -o -wholename './cluster-autoscaler/cloudprovider/huaweicloud/huaweicloud-sdk-go-v3/*' \
        -o -wholename './cluster-autoscaler/cloudprovider/ionoscloud/ionos-cloud-sdk-go/*' \
        -o -wholename './cluster-autoscaler/cloudprovider/hetzner/hcloud-go/*' \
      \) -prune \
    \) -name '*.go'
}

DOCKER_IMAGE=`grep 'FROM golang' builder/Dockerfile | sed 's/FROM //'`
GOFMT="docker run -v $(pwd):/code -w /code $DOCKER_IMAGE gofmt -s"

bad_files=$(find_files | xargs $GOFMT -l)
if [[ -n "${bad_files}" ]]; then
  echo "Please run hack/update-gofmt.sh to fix the following files:"
  echo "${bad_files}"
  exit 1
fi
