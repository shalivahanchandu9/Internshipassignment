# Provider configuration (e.g., AWS)
provider "aws" {
  access_key = "AKIAUA4BZFPEDUX4TX3A"
  secret_key = "oug4Xm5rU72KZAelsJ9Zf3abkDKaIS3Fp0KAJr/U"
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway
resource "aws_internet_gateway" "my_gateway" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create a subnet
resource "aws_subnet" "my_subnet1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
}

resource "aws_subnet" "my_subnet2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
}

# Create a security group for EC2 instances
resource "aws_security_group" "my_sg" {
  name        = "my-security-group"
  description = "Allow SSH and HTTP access"

  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create EC2 instances
resource "aws_instance" "my_instance1" {
  ami           = "ami-007855ac798b5175e"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet1.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  key_name      = "us.east-1.pem"
  associate_public_ip_address = true

  tags = {
    Name = "Instance1"
  }
}

resource "aws_instance" "my_instance2" {
  ami           = "ami-007855ac798b5175e"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.my_subnet2.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]
  key_name      = "us.east-1.pem"
  associate_public_ip_address = true

  tags = {
    Name = "Instance2"
  }
}

# Create a load balancer
resource "aws_lb" "my_lb" {
  name               = "my-lb"
  load_balancer_type = "application"

  subnet_mapping {
    subnet_id = aws_subnet.my_subnet1.id
  }

  subnet_mapping {
    subnet_id = aws_subnet.my_subnet2.id
  }

  security_groups    = [aws_security_group.my_sg.id]
}

# Attach instances to the load balancer target group
resource "aws_lb_target_group" "my_target_group" {
  name        = "my-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my_vpc.id
  target_type = "instance"
}

resource "aws_lb_target_group_attachment" "my_lb_attachment1" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.my_instance1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "my_lb_attachment2" {
  target_group_arn = aws_lb_target_group.my_target_group.arn
  target_id        = aws_instance.my_instance2.id
  port             = 80
}
