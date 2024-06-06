name: core-platform
title: InSpec Profile
license: MIT
version: 0.1.3
supports:
  - platform: aws
depends:
  - name: inspec-aws
    url:  https://github.com/inspec/inspec-aws/archive/v1.83.60.tar.gz
  - name: aws-vpc
    git: https://$GITHUB_TOKEN@github.com/IanHewlett/demo-module-aws-vpc
    tag: $VERSION
    relative_path: spec
