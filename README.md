# Deis 3 Concept

This project demonstrates a bare-bones approach to Deis Workflow. It takes the simplicity of
`git push` that Workflow provides and deploys the application source code using Helm.

Underneath, this project is a combination of:

 - sshd
 - @progrium's [gitreceive](https://progrium/gitreceive), which is the scaffolding around authenticating and executing the builder when `git push` is received
 - A heavily forked incarnation of Deis v1's [builder](https://github.com/deis/deis/blob/master/builder/rootfs/etc/confd/templates/builder)
 - Docker's [Registry v2](https://github.com/docker/distribution) to host the images built by the builder
 - [Helm](https://github.com/kubernetes/helm), which deploys the image onto the cluster

## How it Works

After adding your SSH key to the server (see Usage), when you run `git push` builder will build the
docker image. After it finishes building, builder then pushes the image to the registry which is
running in the same pod. Helm is then told to install a chart with that image, which is deployed
into the same namespace as the git repository's name which you set with `git remote add`.

## Usage

Running the server:

```
# ensure tiller is running on the cluster
helm init
kubectl create -f deis3.yaml
```

Then, to push to it:

```
cat ~/.ssh/id_rsa.pub | kubectl exec -ic deis3 deis3 gitreceive upload-key bacongobbler
git clone https://github.com/deis/example-dockerfile-python
cd example-dockerfile-python
git remote add deis3 ssh://git@k8s.local:2222/appname
git push deis3 master
```

## Known Issues

There are a few known issues with this concept that need addressing:

 - only Dockerfile applications are supported at this time, so there's no buildpack support.
 - need to upload your keys via `kubectl exec` (this might actaully be a good thing).
 - deis3 service is not of type loadbalancer, so it is not exposed by default. I've been just using nodePorts to connect.
 - The kubelets cannot pull the image from the registry in the pod.
 - No `helm upgrade` support (meaning apps can only be deployed once)
