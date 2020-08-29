#!/usr/bin/env bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
source ~/.bashrc 
. ~/.nvm/nvm.sh 
nvm install 12.14.1
