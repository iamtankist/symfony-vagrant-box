#!/bin/sh

echo "Provisioning dev box with puppet"
echo ">> sudo puppet apply manifests/default.pp --modulepath=modules"
echo ""
sudo puppet apply manifests/default.pp --verbose --modulepath=modules
