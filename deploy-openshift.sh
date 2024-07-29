#!/bin/bash

echo "############################################################"
echo "Namespace"
echo "############################################################"

NAMESPACE_SONARQUBE=$1
if [ "$NAMESPACE_SONARQUBE" == "" ]; then
  NAMESPACE_SONARQUBE='sonarqube'
fi
echo "[INFO] Namespace: $NAMESPACE_SONARQUBE"

oc project $NAMESPACE_SONARQUBE &>/dev/null

if [ $? -eq 1 ]; then
  echo "[INFO] Create $NAMESPACE_SONARQUBE namespace first"
  oc new-project $NAMESPACE_SONARQUBE
fi

echo "############################################################"
echo "Build image"
echo "############################################################"
oc new-build . --name=sonarqube --strategy=docker -l "app=sonarqube" --to="image-registry.openshift-image-registry.svc:5000/sonarqube/sonarqube:10.6.0.92116"
sleep 3
oc logs -f bc/sonarqube
echo ""

echo "############################################################"
echo "Install postgresql"
echo "############################################################"
oc apply -k pg/base
echo ""

echo "############################################################"
echo "Install sonarqube"
echo "############################################################"
oc apply -k sonarqube/base
echo ""
