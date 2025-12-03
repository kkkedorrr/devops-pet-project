# 1. NETWORKING LOOKUP
# Instead of creating a new VPC, we look up the Default VPC to save complexity.
data "aws_vpc" "default" {
  default = true
}

# 2. SECURITY GROUP
# Defines who can talk to our server.
resource "aws_security_group" "k8s_sg" {
  name        = "${var.project_name}-sg"
  description = "Allow SSH, HTTP, and K8s API"
  vpc_id      = data.aws_vpc.default.id

  # SSH Access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: In a real job, restrict this to your IP!
  }

  # HTTP App Access
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes API Access (For kubectl from your laptop)
  ingress {
    description = "K8s API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. ECR REPOSITORY
# Where we will store our Docker images
resource "aws_ecr_repository" "app_repo" {
  name                 = "devops-pet-app"
  image_tag_mutability = "MUTABLE"
  force_delete         = true # Allows destroying repo even if it has images
}

# 4. IAM ROLE (The "Identity" of the server)
# The EC2 needs permission to talk to ECR without us saving AWS Keys on the server.
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attach the ECR ReadOnly policy to the role
resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Create an Instance Profile (wrapper) to attach the role to EC2
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}

# 5. AMI LOOKUP
# Find the latest Ubuntu 22.04 AMI dynamically
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu creators)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# 6. SSH KEY PAIR
# Uploads your local public key to AWS
resource "aws_key_pair" "deployer" {
  key_name   = "${var.project_name}-key"
  public_key = file("~/.ssh/k8s-pet-project.pub")
}

# 7. EC2 INSTANCE
resource "aws_instance" "k8s_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer.key_name

  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "${var.project_name}-server"
  }
}
