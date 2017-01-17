# Codebuilder

This project demonstrates a bare-bones approach to building code and uploading to Kubernetes. It
takes the simplicity of `git push` that PaaSes like Deis Workflow and Heroku provides and deploys
the application source code using Helm. After the app has been deployed, the rest is handled by
Kubernetes, including logging, scaling replicas, routing, etc. This gives the user to control the
app after it has been deployed, but at the same time gives them the flexibility of `git push` with
Heroku buildpacks or Dockerfiles.

Underneath, this project is a combination of:

 - sshd
 - @progrium's [gitreceive](https://progrium/gitreceive), which is the scaffolding around authenticating and executing the builder when `git push` is received
 - A heavily forked reincarnation of Deis Workflow's [builder](https://github.com/deis/builder) component
 - Docker's [Registry v2](https://github.com/docker/distribution) to host the images built by codebuilder
 - [Helm](https://github.com/kubernetes/helm), which deploys the image onto the cluster

## How it Works

The project is simply the `codebuilder` container hosting the sshd server w/ gitreceive and the
builder, and another separate `registry` container running in the same pod.

After adding your SSH key to the server (see Usage), when you run `git push` builder will build the
docker image. After it finishes building, builder then pushes the image to the registry which is
running in the same pod. Helm is then told to install a chart with that image, which is deployed
into the same namespace as the git repository's name which you set with `git remote add`.

## Usage

Running the server:

```
# ensure tiller is running on the cluster
$ helm init
$ kubectl create -f codebuilder.yaml
```

Then, to push to it:

```
$ # temporary workaround, add a password to the git user
$ kubectl exec -itc codebuilder codebuilder passwd git
$ cat ~/.ssh/id_rsa.pub | ssh git@k8s.cluster "gitreceive upload-key bacongobbler"
$ git clone https://github.com/deis/example-dockerfile-python
$ cd example-dockerfile-python
$ git remote add k8s ssh://git@k8s.cluster/appname
$ git push k8s master
```

After the push succeeds, check that there's a new release in helm:

```
$ helm list
NAME            REVISION        UPDATED                         STATUS          CHART         
fun-dragon      1               Tue Jan 10 22:00:55 2017        DEPLOYED        appname-v0.1.0
```

And that the app exists in its namespace:

```
$ kubectl --namespace appname get deployment,service,pod
NAME             DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deploy/appname   1         1         1            1           2m
NAME          CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
svc/appname   10.247.27.59   <none>        80/TCP    2m
NAME                          READY     STATUS    RESTARTS   AGE
po/appname-3356271522-5pr91   1/1       Running   0          2m
```

## Known Issues

There are a few known issues with this concept that need addressing:

 - You need to upload your keys via `kubectl exec` (this might actaully be a good thing).
 - SSH keys need to be backed by a configmap; currently SSH keys are stored locally and are lost when the pod is destroyed.
   - same applies to the SSH host keys; they should be backed by a configmap.
 - No `helm upgrade` support is available at this time (meaning apps can only be deployed once).
 - "appname-v0.1.0" is hardcoded as the chart name. This is more of a visual bug.
