#!/bin/bash

CWD=$(cd $(dirname $0);pwd)

## create docker container
docker build -t my/dummy_client:0.0.1 ${CWD}/dummy_client
