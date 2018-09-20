#!/bin/bash
export TF_SCHEMA_PANIC_ON_ERROR=1 
export TF_LOG=TRACE 
rm `pwd`/linode-test.log || true
export TF_LOG_PATH=`pwd`/linode-test.log 
export LINODE_DEBUG=1
terraform apply