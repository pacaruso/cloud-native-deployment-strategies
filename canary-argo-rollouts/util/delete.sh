#!/usr/bin/env bash

cd /tmp/deployment/cloud-native-deployment-strategies

argocd login --core
oc project openshift-gitops
argocd app delete shop -y
oc delete -f canary-argo-rollouts/application-shop-canary-rollouts.yaml

if [ ${1:-no} = "no" ]
then

    oc delete -f canary-argo-rollouts/application-cluster-config.yaml

    currentCSV=$(oc get subscription openshift-pipelines-operator-rh -n openshift-operators -o yaml | grep currentCSV | sed 's/  currentCSV: //')
    echo $currentCSV
    oc delete subscription openshift-pipelines-operator-rh -n openshift-operators
    oc delete clusterserviceversion $currentCSV -n openshift-operators

    currentCSV=$(oc get subscription openshift-gitops-operator -n openshift-operators -o yaml | grep currentCSV | sed 's/  currentCSV: //')
    echo $currentCSV
    oc delete -f gitops/gitops-operator.yaml
    oc delete subscription openshift-gitops-operator -n openshift-operators
    oc delete clusterserviceversion $currentCSV  -n openshift-operators

    oc delete project gitops
fi

git checkout main
git branch -d canary
git push origin --delete canary


