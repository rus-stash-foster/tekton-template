#!/bin/bash

source settings
eval "cat <<EOF 
$(<template.yaml)
EOF" > $PROJECTNAME-tekton.yaml