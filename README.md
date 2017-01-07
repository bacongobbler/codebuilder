# Usage

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
