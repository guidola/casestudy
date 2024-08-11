# Main tf file deploying the entire architecture leveraging the created modules.

# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

# Public Subnet in AZ A
resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.public_subnet_a_cidr
  availability_zone = "eu-west-1a"

  tags = {
    Name = "public-subnet-a"
  }
}

# Public Subnet in AZ B
resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.public_subnet_b_cidr
  availability_zone = "eu-west-1b"

  tags = {
    Name = "public-subnet-b"
  }
}

# Private Subnet in AZ A for Workload Layer
resource "aws_subnet" "private_subnet_wl_a" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_wl_subnet_a_cidr
  availability_zone = "eu-west-1a"

  tags = {
    Name = "private-subnet-a"
  }
}

# Private Subnet in AZ B  for Workload Layer
resource "aws_subnet" "private_subnet_wl_b" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_wl_subnet_b_cidr
  availability_zone = "eu-west-1b"

  tags = {
    Name = "private-subnet-b"
  }
}

# Private Subnet in AZ A for Data Layer
resource "aws_subnet" "private_data_subnet_a" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_data_subnet_a_cidr
  availability_zone = "eu-west-1a"

  tags = {
    Name = "private-subnet-a"
  }
}

# Private Subnet in AZ B  for Data Layer
resource "aws_subnet" "private_data_subnet_b" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_data_subnet_b_cidr
  availability_zone = "eu-west-1b"

  tags = {
    Name = "private-subnet-b"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-igw"
  }
}

# NAT Gateway in Public Subnet A
resource "aws_eip" "nat_eip_a" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw_a" {
  allocation_id = aws_eip.nat_eip_a.id
  subnet_id     = aws_subnet.public_subnet_a.id

  tags = {
    Name = "nat-gateway"
  }
}

# NAT Gateway in Public Subnet B
resource "aws_eip" "nat_eip_b" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw_b" {
  allocation_id = aws_eip.nat_eip_b.id
  subnet_id     = aws_subnet.public_subnet_b.id

  tags = {
    Name = "nat-gateway"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_rt_assoc_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

# Route Table for Private Subnets
resource "aws_route_table" "private_rt_a" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_a.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table" "private_rt_b" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_b.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private_rt_assoc_a_wl" {
  subnet_id      = aws_subnet.private_subnet_wl_a.id
  route_table_id = aws_route_table.private_rt_a.id
}

resource "aws_route_table_association" "private_rt_assoc_b_wl" {
  subnet_id      = aws_subnet.private_subnet_wl_b.id
  route_table_id = aws_route_table.private_rt_b.id
}

# Security Group A (for ALB)
resource "aws_security_group" "sg_a" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-a"
  }
}

# Security Group B (for EKS instances)
resource "aws_security_group" "sg_b" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.sg_a.id]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.sg_a.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-b"
  }
}

# Security Group C (for RDS)
resource "aws_security_group" "sg_c" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.sg_b.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-c"
  }
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "eks-cluster-role"
  }
  depends_on = [ aws_nat_gateway.nat_gw_b, aws_nat_gateway.nat_gw_a ]
}

# IAM Policy Attachment for EKS Cluster Role
resource "aws_iam_role_policy_attachment" "eks_cluster_role_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# IAM Role for EKS Worker Nodes
resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "eks-node-role"
  }
}

# IAM Policy Attachments for EKS Node Role
resource "aws_iam_role_policy_attachment" "eks_node_role_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr_read_only_policy_attachment" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg_a.id]
  subnets            = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.public_subnet_b.id
  ]

  tags = {
    Name = "app-lb"
  }
}

# Target Group for ALB
resource "aws_lb_target_group" "tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "app-tg"
  }
}

# Listener for ALB
resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [
      aws_subnet.private_subnet_wl_a.id,
      aws_subnet.private_subnet_wl_b.id
    ]

    security_group_ids = [aws_security_group.sg_b.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_role_attachment,
  ]

  tags = {
    Name = "eks-cluster"
  }
}

# EKS Node Group
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids         = [
    aws_subnet.private_subnet_wl_a.id,
    aws_subnet.private_subnet_wl_b.id
  ]
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  tags = {
    Name = "eks-node-group"
  }
}

# RDS Subnet Group for Private Subnets
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [
    aws_subnet.private_data_subnet_a.id,
    aws_subnet.private_data_subnet_b.id
  ]

  tags = {
    Name = "rds-subnet-group"
  }
}

# RDS Password
data "aws_ssm_parameter" "rds_password" {
  name = "rds_password"
  with_decryption = true
}

# RDS Instance
resource "aws_db_instance" "rds_instance" {
  identifier              = "rds-instance"
  engine                  = "mysql"
  instance_class          = "db.t3.medium"
  allocated_storage       = 20
  storage_type            = "gp2"
  db_name                 = "db"
  username                = "admin"
  password                = data.aws_ssm_parameter.rds_password.value
  multi_az                = true
  vpc_security_group_ids  = [aws_security_group.sg_c.id]
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  skip_final_snapshot     = true
  apply_immediately       = true
  publicly_accessible     = false

  tags = {
    Name = "rds-instance"
  }
}

# VPC Endpoint for RDS
resource "aws_vpc_endpoint" "rds_endpoint" {
  vpc_id            = aws_vpc.main_vpc.id
  service_name       = "com.amazonaws.${var.region}.rds"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.sg_c.id
  ]
  subnet_ids = [aws_subnet.private_data_subnet_a.id, aws_subnet.private_data_subnet_b.id]

  tags = {
    Name = "rds-endpoint"
  }
}

# ECR Repository
resource "aws_ecr_repository" "ecr_repo" {
  name = "ecr-repo"
  image_tag_mutability = "IMMUTABLE"  

  tags = {
    Name = "ecr-repo"
  }
}

# VPC Endpoint for ECR
resource "aws_vpc_endpoint" "ecr_endpoint" {
  vpc_id            = aws_vpc.main_vpc.id
  service_name       = "com.amazonaws.${var.region}.ecr.api"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.sg_b.id
  ]
  subnet_ids = [aws_subnet.private_subnet_wl_a.id, aws_subnet.private_subnet_wl_b.id]

  tags = {
    Name = "ecr-endpoint"
  }
}

# VPC Endpoint for ECR Docker (for image pulls)
resource "aws_vpc_endpoint" "ecr_docker_endpoint" {
  vpc_id            = aws_vpc.main_vpc.id
  service_name      = "com.amazonaws.${var.region}.ecr.dkr"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.sg_b.id
  ]
  subnet_ids = [aws_subnet.private_subnet_wl_a.id, aws_subnet.private_subnet_wl_b.id]

  tags = {
    Name = "ecr-docker-endpoint"
  }
}
