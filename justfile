#!/usr/bin/env just --justfile

_default:
  @just --list

deploy env:
  just infra/apply {{env}} {{env}}/role/aws-iam
  just infra/apply {{env}} {{env}}/role/vault-pki-root
  just infra/apply {{env}} {{env}}/role/github-bootstrap
  just infra/apply {{env}} {{env}}/role/aws-routing
  just _deploy-instance {{env}} "sbxdev-aws-us-east-2" "us-east-2"
_deploy-instance role instance region:
  just infra/apply {{role}} {{role}}/instance/aws-vpc/{{region}}
  just infra/apply {{role}} {{role}}/instance/aws-eks/{{region}}
  just _update-kubeconfig {{instance}} {{region}}
  just test/test-infra {{role}} {{region}}
  just infra/apply {{role}} {{role}}/instance/flux-bootstrap/{{region}}
  just wait-for-deploy {{role}}
_update-kubeconfig instance region role_arn="arn:aws:iam::$TPL_AWS_ACCOUNT_ID:role/platform-eks-role":
  aws eks update-kubeconfig --name {{instance}} --region {{region}} --role-arn {{role_arn}} --alias {{instance}}

wait-for-deploy role:
  #!/bin/bash
  set -euo pipefail
  wait_for_reconciliation(){
    release_name="$1"
    release_namespace="$2"
    until [[ $(kubectl get kustomization "$release_name" -n "$release_namespace" -o jsonpath="{.status.conditions[?(@.type=='Ready')]}" | jq -r .reason) == "ReconciliationSucceeded" ]] && \
    [[ $(kubectl get kustomization "$release_name" -n "$release_namespace" -o jsonpath="{.status.conditions[?(@.type=='Ready')]}" | jq -r .status) == "True" ]]
    do
      echo "$release_name" not ready
      sleep 10
    done
    echo "$release_name reconciled"
  }
  for svc in $(jq -rc '.[]' "./infra/{{role}}/services.json"); do
    wait_for_reconciliation "$(echo "$svc" | jq -r '.name')" "$(echo "$svc" | jq -r '.namespace')"
  done
  for app in $(jq -rc '.[]' "./infra/{{role}}/applications.json"); do
    wait_for_reconciliation "$(echo "$app" | jq -r '.name')" "$(echo "$app" | jq -r '.namespace')"
  done

clean env:
  just _clean-instance {{env}} "sbxdev-aws-us-east-2" "us-east-2"
  just infra/destroy {{env}} {{env}}/role/aws-routing
  just infra/destroy {{env}} {{env}}/role/github-bootstrap
  just infra/destroy {{env}} {{env}}/role/vault-pki-root
  just infra/destroy {{env}} {{env}}/role/aws-iam
_clean-instance role instance region:
  just infra/destroy {{role}} {{role}}/instance/flux-bootstrap/{{region}}
  just infra/destroy {{role}} {{role}}/instance/aws-eks/{{region}}
  just infra/destroy {{role}} {{role}}/instance/aws-vpc/{{region}}
