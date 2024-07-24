resource "aws_vpc" "new_proj" {
  cidr_block = var.aws_vpc

  tags = {
    Name = "newvpc"
  }
}
resource "aws_subnet" "public_subnet" {
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = aws_vpc.new_proj.id
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name                              = "public_subnet"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"      = "owned"
  }
}
resource "aws_subnet" "public_subnet2" {
  cidr_block              = "10.0.2.0/24"
  vpc_id                  = aws_vpc.new_proj.id
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = true


  tags = {
    Name                              = "public_subnet2"
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/demo"      = "owned"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.new_proj.id
  tags = {
    Name = "IGW"
  }

}

resource "aws_route_table" "newtable" {
  vpc_id = aws_vpc.new_proj.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  // ... other configuration options for the route table
}

resource "aws_route_table_association" "rt" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.newtable.id

}
resource "aws_route_table_association" "rtsub2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.newtable.id

}
module "sgmodule" {
  source = "./Modules/securitygroup"        
  vpc_id = aws_vpc.new_proj.id
}







# resource "aws_instance" "newpublic-ins" {
#   ami                    = "ami-0866a04d72a1f5479"
#   subnet_id              = aws_subnet.public_subnet.id
#   availability_zone      = "us-east-2a" # Specify the desired availability zone
#   vpc_security_group_ids = [aws_security_group.secgp.id]
#   # key_name               = "keyok" # Replace with your SSH key name
#   # Other instance configuration options like instance type, etc.
#   instance_type = "t2.micro"
#   associate_public_ip_address = "true"

#   tags = {
#     name = "docker"
#   }
# }

# resource "aws_instance" "jenkins-ins" {
#   ami                    = "ami-0866a04d72a1f5479"
#   subnet_id              = aws_subnet.public_subnet.id
#   availability_zone      = "us-east-2a"
#   vpc_security_group_ids = [aws_security_group.secgp.id]
#   key_name               = "keyok"
#   instance_type          = "t2.micro"
#   associate_public_ip_address = true

#   tags = {
#     name = "jenkins"
#   }

#   user_data = <<-EOF
#               #!/bin/bash
#               sudo -i
#               sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
#               sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
#               sudo yum upgrade -y
#               sudo yum install -y fontconfig java-17-openjdk
#               sudo yum install -y jenkins
#               sudo systemctl daemon-reload
#               yum install java -y
#               sudo systemctl enable jenkins
#               sudo systemctl start jenkins
#               sudo yum install -y docker
#               sudo systemctl enable docker
#               sudo systemctl start docker
#             EOF
# }

# output "instance_ip_addr" {
#   value = aws_instance.jenkins-ins.public_ip

# }

# cluster role was here

# resource "aws_iam_role" "eks_cluster_role" {
#   name = "eks-cluster-role"
 
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Action = "sts:AssumeRole",
#         Effect = "Allow",
#         Principal = {
#           Service = "eks.amazonaws.com",
#         },
#       },
#     ],
#   })
# }
# resource "aws_iam_policy_attachment" "eks_cluster_policy_attachment" {
#   name       = "eks-cluster-policy-attachment"
#   roles      = [aws_iam_role.eks_cluster_role.name]
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
# }

# resource "aws_eks_cluster" "newcicd" {
#   name     = "eksci"
#   role_arn = aws_iam_role.eks_cluster_role.arn
#   version  = 1.28

#   vpc_config {
#     subnet_ids = [aws_subnet.public_subnet.id, aws_subnet.public_subnet2.id]
#   }
#   depends_on = [aws_iam_policy_attachment.eks_cluster_policy_attachment,]

# }

# resource "aws_iam_role" "noderole" {
#   name = "workernoderole"

#   assume_role_policy = jsonencode({
#     Statement = [{
#       Action = "sts:AssumeRole"
#       Effect = "Allow"
#       Principal = {
#         Service = "ec2.amazonaws.com"
#       }
#     }]
#     Version = "2012-10-17"
#   })
# }

# resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.noderole.name
# }

# resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.noderole.name
# }

# resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   role       = aws_iam_role.noderole.name
# }

# resource "aws_eks_node_group" "ttylnodegp" {
#   cluster_name    = aws_eks_cluster.newcicd.name
#   node_group_name = "ttylnode"
#   node_role_arn   = aws_iam_role.noderole.arn
#   subnet_ids      = [aws_subnet.public_subnet.id, aws_subnet.public_subnet2.id]
#   instance_types  = ["t3.medium"]
#   # capacity_type = "ON_DEMAND"

#   tags = { "k8s.io/cluster-autoscaler/enabled" = "true"
#     "k8s.io/cluster-autoscaler/eksci"                    = "owned"
#     "k8s.io/cluster-autoscaler/node-template/label/role" = "tttylnode"
#   }

#   scaling_config {
#     desired_size = 2
#     max_size     = 4
#     min_size     = 1
#   }
#   update_config {
#     max_unavailable = 1

#   }
#   depends_on = [
#     aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
    
#   ]
  
# }


resource "aws_iam_user" "eksuser" {
  name = "eksuser"
  
  
}
resource "aws_iam_group" "eksuser-full-access-group" {
  name = "eksuser-full-access-group"
}
resource "aws_iam_group_membership" "member" {
  name = "usermember"

  users = [ aws_iam_user.eksuser.name ]
  group = aws_iam_group.eksuser-full-access-group.name
  depends_on = [ aws_iam_group.eksuser-full-access-group ]
  
}

resource "aws_iam_policy" "eks_node_view" {
  name        = "eks-policy"
  description = "Policy for EKS access"
  
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:ListFargateProfiles",
        "eks:DescribeNodegroup",
        "eks:ListNodegroups",
        "eks:ListUpdates",
        "eks:AccessKubernetesApi",
        "eks:ListAddons",
        "eks:DescribeCluster",
        "eks:DescribeAddonVersions",
        "eks:ListClusters",
        "eks:ListIdentityProviderConfigs",
        "iam:ListRoles"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
resource "aws_iam_group_policy_attachment" "attachment" {
  group = aws_iam_group.eksuser-full-access-group.name
  policy_arn = aws_iam_policy.eks_node_view.arn
}


resource "aws_iam_access_key" "eksuser_access_key" {
  user = aws_iam_user.eksuser.name
}

resource "aws_iam_user_login_profile" "eksuser_login_profile" {
  user                    = aws_iam_user.eksuser.name
  password_length         = 20
  password_reset_required = false
}

resource "aws_iam_group" "eks_console_access_group" {
  name = "eks_console_access_group"
}

resource "aws_iam_group_membership" "eksuser_group_membership" {
  name = "eksuser_group_membership"
  users = [aws_iam_user.eksuser.name]
  group = aws_iam_group.eks_console_access_group.name
}

#--------------------
# data "tls_certificate" "eks" {
#   url = aws_eks_cluster.newcicd.identity[0].oidc[0].issuer
# }
 
# resource "aws_iam_openid_connect_provider" "eks" {
#   client_id_list  = ["sts.amazonaws.com"]
#   thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
#   url             = aws_eks_cluster.newcicd.identity[0].oidc[0].issuer
# }
 
# data "aws_iam_policy_document" "eks_cluster_autoscaler_assume_role_policy" {
#   statement {
#     actions = ["sts:AssumeRoleWithWebIdentity"]
#     effect  = "Allow"
 
#     condition {
#       test     = "StringEquals"
#       variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
#       values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
#     }
 
#     principals {
#       identifiers = [aws_iam_openid_connect_provider.eks.arn]
#       type        = "Federated"
#     }
#   }
# }
 
# resource "aws_iam_role" "eks_cluster_autoscaler" {
#   assume_role_policy = data.aws_iam_policy_document.eks_cluster_autoscaler_assume_role_policy.json
#   name               = "eks-cluster-autoscaler"
# }
 
# resource "aws_iam_policy" "eks_cluster_autoscaler" {
#   name = "eks-cluster-autoscaler"
 
#   policy = jsonencode({
#     Statement = [{
#       Action = [
#                 "autoscaling:DescribeAutoScalingGroups",
#                 "autoscaling:DescribeAutoScalingInstances",
#                 "autoscaling:DescribeLaunchConfigurations",
#                 "autoscaling:DescribeTags",
#                 "autoscaling:SetDesiredCapacity",
#                 "autoscaling:TerminateInstanceInAutoScalingGroup",
#                 "ec2:DescribeLaunchTemplateVersions"
#             ]
#       Effect   = "Allow"
#       Resource = "*"
#     }]
#     Version = "2012-10-17"
#   })
# }