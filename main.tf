provider "aws" {
  region = "ap-south-1"
}

# ---------------- S3 State Bucket ----------------
resource "aws_s3_bucket" "tf_state" {
  bucket = var.s3_bucket_name

  tags = {
    Name = "${var.Project_name}-tf-state-bucket"
  }
}

resource "aws_s3_bucket_versioning" "tf_state_versioning" {
  bucket = aws_s3_bucket.tf_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ---------------- VPC ----------------
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.Project_name}-vpc"
  }
}

# ---------------- Internet Gateway ----------------
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.Project_name}-igw"
  }
}

# ---------------- Subnets ----------------
resource "aws_subnet" "pub_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.pub_cidr
  availability_zone       = var.az1
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.Project_name}-public-subnet"
  }
}

resource "aws_subnet" "pvt_subnet1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.pvt_cidr
  availability_zone = var.az1

  tags = {
    Name = "${var.Project_name}-private-subnet-1"
  }
}

resource "aws_subnet" "pvt_subnet2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.pvt_cidr2
  availability_zone = var.az2

  tags = {
    Name = "${var.Project_name}-private-subnet-2"
  }
}

# ---------------- Route Table ----------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.Project_name}-public-rt"
  }
}

resource "aws_route" "igw_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = var.igw_cidr
  gateway_id             = aws_internet_gateway.my_igw.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.pub_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# ---------------- Security Group ----------------
resource "aws_security_group" "ec2_sg" {
  name   = "${var.Project_name}-sg"
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.igw_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.igw_cidr]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.igw_cidr]
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.igw_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.igw_cidr]
  }

  tags = {
    Name = "${var.Project_name}-sg"
  }
}

# ---------------- EC2 Instances ----------------
resource "aws_instance" "web_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.pub_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.key_pair

  tags = merge(var.tags, {
    Name = "web-server"
  })
}

resource "aws_instance" "app_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.pub_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.key_pair

  tags = merge(var.tags, {
    Name = "app-server"
  })
  
}

resource "aws_instance" "db_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.pub_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name               = var.key_pair

  tags = merge(var.tags, {
    Name = "db-server"
  })
}

resource "aws_key_pair" "piyush_key" {
  key_name   = var.key_pair
  public_key = file("piyush-key.pub")
}
