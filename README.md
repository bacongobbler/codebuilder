# Usage

Running the server:

```
docker build -t deis3-concept .
docker run --name registry -dp 5000:5000 registry:2.3.1
docker run -dp 2222:2222 -v /var/run/docker.sock:/var/run/docker.sock --link registry:registry --name deis3-concept deis3-concept
```

Then, to push to it:

```
cat ~/.ssh/id_rsa.pub | docker exec -i deis3-concept gitreceive upload-key bacongobbler
git clone https://github.com/deis/example-dockerfile-python
cd example-dockerfile-python
git remote add deis3 ssh://bacongobbler@localhost:2222/appname
git push deis3 master
```
