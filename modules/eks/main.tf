data "aws_vpc" "stackset_vpc" {
  filter {
    name   = "tag:aws:cloudformation:logical-id"
    values = ["VPC"]
  }
}  

# Retrieve Public Subnets
data "aws_subnet" "private_subnet_1" {
  filter {
    name   = "tag:aws:cloudformation:logical-id"
    values = ["PrivateSubnet2A"]
  }
}

# Retrieve Public Subnets
data "aws_subnet" "private_subnet_2" {
  filter {
    name   = "tag:aws:cloudformation:logical-id"
    values = ["PrivateSubnet1A"]
  }
}

# Security Group for EKS Cluster
resource "aws_security_group" "eks_cluster_sg" {
  vpc_id = data.aws_vpc.stackset_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your public IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks-cluster-sg"
  }
}

# EKS Cluster
resource "aws_eks_cluster" "my_cluster" {
  name     = "qa-cluster"  # Change to your cluster name
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = [data.aws_subnet.private_subnet_1.id, data.aws_subnet.private_subnet_2.id]
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }

  depends_on = [aws_iam_role_policy_attachment.eks_policy]
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_role" {
  name               = "eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy.json
}

data "aws_iam_policy_document" "eks_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

# Attach the necessary policies to the EKS role
resource "aws_iam_role_policy_attachment" "eks_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Node Group
resource "aws_eks_node_group" "my_node_group" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "qa-node-group"  
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = [data.aws_subnet.private_subnet_1.id,  data.aws_subnet.private_subnet_2.id]

  scaling_config {
    desired_size = 2  
    max_size     = 3
    min_size     = 1
  }

  depends_on = [aws_eks_cluster.my_cluster]
}

# IAM Role for EKS Node Group
resource "aws_iam_role" "eks_node_group_role" {
  name               = "qa-eks-node-group-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_group_assume_role_policy.json
}

data "aws_iam_policy_document" "eks_node_group_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Attach policies to the Node Group role
resource "aws_iam_role_policy_attachment" "eks_node_group_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_registry_policy" {
  role       = aws_iam_role.eks_node_group_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

output "cluster_endpoint" {
  value = aws_eks_cluster.my_cluster.endpoint
}

output "cluster_name" {
  value = aws_eks_cluster.my_cluster.name
}
