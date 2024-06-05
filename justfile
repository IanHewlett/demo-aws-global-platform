#!/usr/bin/env just --justfile

_default:
  @just --list

deploy env:
  just infra/apply {{env}} {{env}}/role/aws-iam
  just infra/apply {{env}} {{env}}/role/vault-pki-root

clean env:
  just infra/destroy {{env}} {{env}}/role/vault-pki-root
  just infra/destroy {{env}} {{env}}/role/aws-iam
