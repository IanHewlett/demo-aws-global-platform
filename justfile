#!/usr/bin/env just --justfile

_default:
  @just --list

deploy env:
  just infra/apply {{env}} {{env}}/role/aws-iam
  just infra/apply {{env}} {{env}}/role/vault-pki-root
  just _deploy-instance {{env}} "sbxdev-aws-us-east-2" "us-east-2"
_deploy-instance role instance region:
  just infra/apply {{role}} {{role}}/instance/aws-vpc/{{region}}

clean env:
  just _clean-instance {{env}} "sbxdev-aws-us-east-2" "us-east-2"
  just infra/destroy {{env}} {{env}}/role/vault-pki-root
  just infra/destroy {{env}} {{env}}/role/aws-iam
_clean-instance role instance region:
  just infra/destroy {{role}} {{role}}/instance/aws-vpc/{{region}}
