variable "s3_bucket_name" {
  type    = string
  default = "piyush-terraform-state-bucket-2024"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "pub_cidr" {
  default = "10.0.16.0/20"
}

variable "pvt_cidr" {
  default = "10.0.0.0/20"
}

variable "pvt_cidr2" {
  default = "10.0.32.0/20"
}

variable "az1" {
  default = "ap-south-1a"
}

variable "az2" {
  default = "ap-south-1b"
}

variable "Project_name" {
  default = "fct"
}

variable "igw_cidr" {
  default = "0.0.0.0/0"
}

variable "ami_id" {
  default = "ami-0d176f79571d18a8f"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_pair" {
  default = "piyush-key"
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "dev"
    Owner       = "piyush"
  }
}
