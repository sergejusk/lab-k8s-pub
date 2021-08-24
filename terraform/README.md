# K8s cluster on AWS (eks)
This repo should be used for test purpose.
Structure for this lab are taken as simple as possible and still close to production
 1. Workers will span on private subnet
 2. Only one NAT gateway will be used
 3. 3 availability zone for Workers
 4. Will add your external IP to cluster access list 

## On create
```
cd terraform
terraform apply # check and confirm with "yes"
aws eks update-kubeconfig --name test-k8s # update k8s configuration on you PC
```

## On destroy
```
terraform state rm "module.eks.kubernetes_config_map.aws_auth[0]" # sometimes its try to remove it not in correct order and will fail destroy, so better remove before
terrafrom destroy # check and confirm with "yes"
```
