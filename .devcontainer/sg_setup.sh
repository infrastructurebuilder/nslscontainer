#!/bin/sh
pip3 install -r requirements.txt
pip3 install -r requirements.dev.txt
# Install serverless plugins
serverless plugin install -n serverless-python-requirements
