provider "aws" {
  region              = "us-east-2"
  shared_config_files = ["C:/Users/subramanim/.aws/config"]
  
}



# provider "kubernetes" {
#   config_path    = "C:/Users/subramanim/.kube/config"
#   config_context = "arn:aws:eks:us-east-2:106007593412:cluster/eksci"

# }

# provider "kubernetes" {
#   config_path    = "C:/Users/subramanim/.kube/config"  # Adjust the path to point to the kubeconfig file
#   config_context = "arn:aws:eks:us-east-2:106007593412:cluster/eksci"
# }

