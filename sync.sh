#!/bin/bash
cd $(dirname $0)
rsync -av --itemize-changes bin /home/local/
