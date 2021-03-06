#!/bin/bash

set -e

echo "-----> `date`: Create dev release"
cpi_path=/tmp/kube-cpi
bosh create-release --force --dir ./../../ --tarball $cpi_path

echo "-----> `date`: Get latest bosh-deployment"
rm -rf bosh-deployment
git clone https://github.com/cloudfoundry/bosh-deployment

echo "-----> `date`: Deploy Director"
bosh create-env ./bosh-deployment/bosh.yml \
  --state=state.json \
  --vars-store=creds.yml \
  -o ../../bosh-deployment/k8s/cpi.yml \
  -o ../../bosh-deployment/k8s/gcp.yml \
  -o ./bosh-deployment/jumpbox-user.yml \
  -o ./bosh-deployment/misc/config-server.yml \
  -o ./bosh-deployment/uaa.yml \
  -o ../../manifests/dev.yml \
  -v director_name=kube-gke \
  -v internal_cidr="unused" \
  -v internal_gw="unused" \
  -v internal_ip=${BOSH_RUN_LB_IP} \
  --var-file kube_config=<(cat ./kubeconfig) \
  -v kubernetes_cpi_path=/tmp/kube-cpi \
  --var-file gcr_password=gcr-password.json \
  -v gcr_pull_secret_name=regsecret \
  -v kube_api=${BOSH_RUN_KUBE_API_IP} \
  -o ../generic/local.yml
