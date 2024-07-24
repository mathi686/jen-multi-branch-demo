resource "null_resource" "eks_cluster_upgrade1" {
  provisioner "local-exec" {
    command = "aws eks update-cluster-version --region us-east-2 --name eksci --kubernetes-version 1.28"
  }
}
