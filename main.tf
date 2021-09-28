# https://registry.terraform.io/providers/hashicorp/aws/latest/docs

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.60"
    }
  }

  required_version = ">= 1.0"
}

provider "aws" {
  profile = "default"
  region  = "eu-west-2" # london

  default_tags {
    tags = {
      role = var.name
    }
  }
}

variable "ami" {
  description = "ami id"
  type        = string
}

variable "instance_type" {
  type        = string
  description = "ec2 instance type"
}

variable "name" {
  type        = string
  description = "environment name"
}

variable "vpc_id" {
  type        = string
  description = "vpc id"
}

variable "kms_key_arn" {
  type        = string
  description = "ebs kms key arn"
}

variable "subnet" {
  type        = string
  description = "subnet id"
}

resource "aws_instance" "instance" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet
  associate_public_ip_address = true
  key_name                    = aws_key_pair.key.key_name

  vpc_security_group_ids = [
    aws_security_group.security_group.id,
  ]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 80
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = var.kms_key_arn
    iops                  = 3000
    throughput            = 125
    tags = {
      Name = var.name
      role = var.name
    }
  }

  tags = {
    Name = var.name
  }
}

resource "aws_security_group" "security_group" {
  name        = var.name
  description = var.name
  vpc_id      = var.vpc_id

  ingress = [
    {
      cidr_blocks = [
        "0.0.0.0/0"
      ]
      description      = "ssh"
      from_port        = 22
      protocol         = "tcp"
      to_port          = 22
      self             = false
      security_groups  = []
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
    }
  ]

  egress = [
    {
      cidr_blocks = [
        "0.0.0.0/0"
      ]
      description      = "all"
      from_port        = 0
      protocol         = "-1"
      to_port          = 0
      self             = false
      security_groups  = []
      ipv6_cidr_blocks = [
        "::/0"
      ]
      prefix_list_ids  = []
    }
  ]
}

resource "aws_key_pair" "key" {
  key_name   = var.name
  public_key = file("./key.pub")
}

output "ip" {
  value = aws_instance.instance.public_ip
}

output "instance-id" {
  value = aws_instance.instance.id
}
