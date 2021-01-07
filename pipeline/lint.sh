#!/bin/bash
# shellcheck disable=SC2044
set -xe

TERRAFORM="${TERRAFORM:-terraform-0.13}"

$TERRAFORM -v

cp providers.tf.example providers.tf
$TERRAFORM init
$TERRAFORM fmt -check=true
$TERRAFORM validate -var "deployment_id=validate" -var "route53_domain=validate-fake.com" -var "admin_email=fake@mailinator.com"
for example in $(find examples -maxdepth 1 -mindepth 1 -type d); do
  cp providers.tf "$example"
  (
    cd "$example"
    echo "$example"
    $TERRAFORM init
    $TERRAFORM fmt -check=true
    $TERRAFORM validate -var "deployment_id=citest"
  )
done
