#!/bin/bash

if [ -z "$1" ] ; then
  source settings
else
  source $1
fi

mkdir -p $PROJECTNAME
cp settings $PROJECTNAME

# Create tekton template

eval "cat <<EOF 
$(<template.yaml)
EOF" > $PROJECTNAME/$PROJECTNAME-tekton.yaml

# Create ecr template
# eval "cat <<EOF 
#$(<config-json-template.json)
#EOF" > $PROJECTNAME/$PROJECTNAME-ecr-config.json
cp config-json-template.json $PROJECTNAME/config.json

echo NAMESPACE="${NAMESPACE}" > $PROJECTNAME/namespace

cat <<EOF>$PROJECTNAME/start.sh
#!/bin/bash
kubectl create namespace $NAMESPACE
kubectl --namespace $NAMESPACE create configmap docker-config --from-file=config.json
sleep 3
kubectl --namespace $NAMESPACE apply -f  $PROJECTNAME-tekton.yaml
EOF

cat <<EOF>$PROJECTNAME/stop.sh
#!/bin/bash
kubectl --namespace $NAMESPACE delete configmap docker-config
kubectl --namespace $NAMESPACE delete -f  $PROJECTNAME-tekton.yaml
kubectl delete namespace $NAMESPACE
EOF

chmod 755 $PROJECTNAME/*.sh