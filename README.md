# kub-fed-blog
This repository contains the code samples to support the blog post on the matter

# Provision an Environment

After installing the AWS CLI. Configure it to use your credentials.

```shell
$ aws configure
AWS Access Key ID [None]: <YOUR_AWS_ACCESS_KEY_ID>
AWS Secret Access Key [None]: <YOUR_AWS_SECRET_ACCESS_KEY>
Default region name [None]: <YOUR_AWS_REGION>
Default output format [None]: json
```

This enables Terraform access to the configuration file and performs operations on your behalf with these security credentials.

After you've done this, initalize your Terraform , which will download 
the providers and modules.

```shell
$ terraform init
```

In this example all configurations are already prepared in resources so you just need to plan and apply.

```shell
$ terraform plan
$ terraform apply 
```

## Configure kubectl

Unsetting all environment variables in case you have them in your system.And you need to set you AWS Account ID's and EKS endpoints.

```shell
unset AWS_ACCOUNT_ID
unset EKS_1_NAME
unset EKS_1_ENDPOINT
unset EKS_1_REGION
unset EKS_2_NAME
unset EKS_2_ENDPOINT
unset EKS_2_REGION

export AWS_ACCOUNT_ID=xxxxxxxxx
export EKS_1_NAME=eks-federated-1
export EKS_1_ENDPOINT=xxxxxxxxxxxxxxxxxxxx.gr7.us-east-1.eks.amazonaws.com
export EKS_1_REGION=us-east-1
export EKS_2_NAME=eks-federated-2
export EKS_2_ENDPOINT=xxxxxxxxxxxxxxxxxxxx.yl4.us-west-2.eks.amazonaws.com
export EKS_2_REGION=us-west-2
```

To configure kubetcl, you need both [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and [AWS IAM Authenticator](https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html).

The following command will get the access credentials for your cluster and automatically
configure `kubectl`.

```shell
$ aws eks update-kubeconfig --name ${EKS_1_NAME} --region ${EKS_1_REGION}
$ aws eks update-kubeconfig --name ${EKS_2_NAME} --region ${EKS_2_REGION}
```

```shell
$ kubectl config rename-context $(kubectl config get-contexts --no-headers=true -o name | grep ${EKS_1_REGION}:${AWS_ACCOUNT_ID}) ${EKS_1_NAME}.${EKS_1_REGION}
$ kubectl config rename-context $(kubectl config get-contexts --no-headers=true -o name | grep ${EKS_2_REGION}:${AWS_ACCOUNT_ID}) ${EKS_2_NAME}.${EKS_2_REGION}
```

```shell
$ kubectl config use-context eks-federated-1
$ helm repo add kubefed-charts https://raw.githubusercontent.com/kubernetes-sigs/kubefed/master/charts
$ helm repo update
$ helm --namespace kube-federation-system upgrade --install kubefed kubefed-charts/kubefed --create-namespace --version 0.10.0
$ kubefedctl join ${EKS_1_NAME}.${EKS_1_REGION} --cluster-context ${EKS_1_NAME}.${EKS_1_REGION} --host-cluster-context ${EKS_1_NAME}.${EKS_1_REGION} --v=2 
$ kubefedctl join ${EKS_2_NAME}.${EKS_2_REGION} --cluster-context ${EKS_2_NAME}.${EKS_2_REGION} --host-cluster-context ${EKS_1_NAME}.${EKS_1_REGION} --v=2 
$ kubectl -n kube-federation-system get kubefedclusters
```

## Deploy Demo Application

```shell
$ kubectl apply -f echo-server/federated-namespace.yaml
$ kubectl apply -f echo-server/federated-deployment.yaml
$ kubectl apply -f echo-server/federated-service.yaml
```
