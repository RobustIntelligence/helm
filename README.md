# RIME's Helm charts

## The RIME Helm Repository

Here we describe how to maintain and release packages for RIME's Helm charts.

### Location of the RIME Helm Repository

Currently our repository is located in a Google Cloud Services (GCS) bucket here:

```
gs://rime-backend-helm-repository
```

### Authentication

First you need to login on the commandline to GCS:

```
gcloud auth application-default login
```

This will open a login prompt for Google.  Login as a role with access to the
Helm repository (eg. dev@robustintelligence.com).

### Install GCS Helm Plugin

Add the GCS Helm plugin using the following commands

```
helm plugin install https://github.com/hayorov/helm-gcs.git
helm plugin update gcs
```

### Add the RIME Repository

Add the RIME Repository to your Helm repo list with the following command

```
helm gcs add rime gs://rime-backend-helm-repository
```

### Build and Push new version

To build a new version of the RIME charts, select a new
[semantic versioning number](https://semver.org/); e.g. 0.11.0 which will
correspond to `v11`. Next run the following command:

```
make VERSION=$VERSION APP_VERSION=$APP_VERSION push_rime_chart_release
```

where `$VERSION` is your semantic version number and `$APP_VERSION` is your
application version.

#### Errors:

If you get an error like:

```
Error: chart rime-0.4.0 already indexed. Use --force to still upload the chart
```

Please stop and carefully consider how to proceed. You are attempting to overwrite
a chart that already exists which could break existing users. Likely you should
choose a new version number.

### Notes:

To create an initial Helm repository in GCS you need to do

```
helm gcs init gs://bucket/path
```

**Do Not** re-run this command for an existing repository.

## Development for RIME's charts

Here we describe how to develop and test RIME's Helm charts.

### Setup instructions for the local dev environment
1. Make sure you have Minikube and Helm installed (see depenecies section in the root README.md).
1. If you don't have a Minikube cluster running locally start one with `minikube start`
1. Point your shell to minikube's docker-daemon by running `eval $(minikube -p minikube docker-env)`
1. In the same shell that is using minikube's docker-daemon, build the backend Docker image by running (from the repository's root): `make rime_microservices_docker`
1. In the same shell, verify that the image is available in minkube by running `docker images`
1. From the chart directory run: `helm dependency update`
1. You're now ready to install the helm chart, run: `helm install rime ./`
1. Get the URLs for interacting with each service by running `minikube service <service_name>`. You can list out service names with `kubectl get service`. (if you don't want to rely on tunnelling then minikube must be started using a VM driver like hyperkit, `minikube start --vm-driver=hyperkit`, you can download hyperkit using `brew install hyperkit`)

### Debugging tips

- Check the docker images by running `docker images` but make sure you have already pointed your shell to minikube's docker-daemon with `eval $(minikube -p minikube docker-env)`
- Check the pods with `kubectl get pod`
- Check the logs inside a pod with `kubectl logs <pod_name>`. You can get the pod names with `kubectl get pod`.
- You can check the logs of an already crashed pod with `kubectl logs <pod_name> --previous`
- Check the services information with `kubectl get service`
- Check all resources deployed in the cluster with `kubectl get all`
- Get detailed description about a resource with `kubectl describe <resource_type> <resource_name>`


### Updating just the staging deployment's images

- Push a new image to robustintelligencehq/rime-backend:latest
- `kubectl rollout restart deployment/rime`

### Deploying to RIME staging (on EKS)

After going through the setup steps below, the commands to deploy are:
```
helm dependency update
helm install --debug --values staging.yaml rime ./
```

#### Setup

1. Install and configure `AWS CLI`, [Details](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html#cli-configure-quickstart-creds)
    - [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
     No prerequisites are needed as we use a shared eng AWS account.
   - `aws configure` will ask for `Access Key ID` and `Secret Access Key`,
       the information can be found in Onepassword, under in `eng user (AWS)`.
   - The default region should be `us-west-2`
2. Confirm the configuration by using `aws sts get-caller-identity`, it should
   show the correct account info.
3. Install `kubectl`
   - If you have already installed `minikube`, you may have latest `kubectl` as
     it is needed from `minikube`. Use `kubectl version --client --short` to 
     check. Latest version should work.
   - `kubectl` version should be within one minor version difference of
     our Amazon EKS cluster control plane, according to [AWS installation instructions](https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html))
     Currently, the version is 1.20.
     You can either use the link above to install or find the right version 
     from [K8s](https://kubernetes.io/releases/) directly.
     For M1 Mac, use `arm64` instead of `amd64`.
   - To check eks cluster version, use 
     `aws eks describe-cluster --name rime-latest`
5. `aws eks update-kubeconfig --name <CLUSTER_NAME> --region us-west-2`
   where `<CLUSTER_NAME>` is the name of the cluster you want to apply your changes to (e.g. `rime-staging`).

#### Granting EKS access permissions to a new IAM user

1. Get the user arn for the user your granting access to
2. Make sure the IAM user is added to the Engineering group
3. `kubectl edit configmap aws-auth -n kube-system`
    1. Add:

        ```yaml
        mapUsers: |
          - userarn: arn:aws:iam::XXXXXXXXXXXX:user/testuser
            username: testuser
            groups:
              - system:masters
        ```
