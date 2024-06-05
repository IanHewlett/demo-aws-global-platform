#!/usr/bin/env just --justfile

_default:
  @just --list

deploy env:
  just infra/apply {{env}} {{env}}/role/aws-iam

clean env:
  just infra/destroy {{env}} {{env}}/role/aws-iam
