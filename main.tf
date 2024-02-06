resource "aws_vpc" "new_proj" {
  cidr_block = var.aws_vpc

  tags = {
    Name = "newvpc"
  }
}
resource "aws_subnet" "public_subnet" {
  cidr_block        = "10.0.1.0/24"
  vpc_id            = aws_vpc.new_proj.id
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}
resource "aws_subnet" "public_subnet2" {
  cidr_block        = "10.0.2.0/24"
  vpc_id            = aws_vpc.new_proj.id
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = true
  

  tags = {
    Name = "public-subnet2"
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
resource "aws_security_group" "secgp" {
  name   = "new_secgp"
  vpc_id = aws_vpc.new_proj.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_instance" "newpublic-ins" {
#   ami                    = "ami-0866a04d72a1f5479"
#   subnet_id              = aws_subnet.public_subnet.id
#   availability_zone      = "us-east-2a" # Specify the desired availability zone
#   vpc_security_group_ids = [aws_security_group.secgp.id]
#   key_name               = "keyok" # Replace with your SSH key name
#   # Other instance configuration options like instance type, etc.
#   instance_type = "t2.micro"
#   associate_public_ip_address = "true"

#   tags = {
#     name = "keyok"
#   }
# }

# Create an IAM Role
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com",
        },
      },
    ],
  })
}
resource "aws_iam_policy_attachment" "eks_cluster_policy_attachment" {
  name       = "eks-cluster-policy-attachment"
  roles      = [aws_iam_role.eks_cluster_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


resource "aws_eks_cluster" "newcicd" {
  name     = "eksci"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.public_subnet.id, aws_subnet.public_subnet2.id]
  }
  depends_on = [aws_iam_policy_attachment.eks_cluster_policy_attachment]

}

resource "aws_iam_role" "noderole" {
  name = "workernoderole"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.noderole.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.noderole.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.noderole.name
}

resource "aws_eks_node_group" "ttylnodegp" {
  cluster_name    = aws_eks_cluster.newcicd.name
  node_group_name = "ttylnode"
  node_role_arn   = aws_iam_role.noderole.arn
  subnet_ids      = [aws_subnet.public_subnet.id, aws_subnet.public_subnet2.id]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }
  update_config {
    max_unavailable = 1
  }
  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.example-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.example-AmazonEC2ContainerRegistryReadOnly,
  ]
}

