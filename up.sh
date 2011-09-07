#!/bin/bash
# example: hndest=joe@example.com:public_html
rsync --exclude '.git*' -e ssh -avz `pwd` $hndest
