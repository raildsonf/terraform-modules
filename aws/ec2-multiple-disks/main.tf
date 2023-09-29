provider "aws" {
  region = "us-east-2"
}

data "aws_ami" "web" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

variable "number_of_devices" {
  type    = number
  default = 3
}

locals {
  common_tags = {
    Name = "webapp"
    TEAM = "GK",
    STACK = "webtier"
    OU = "SRE"
  }
  device_names = tolist([
    "/dev/sda",
    "/dev/sdb",
    "/dev/sdc"
  ])
}

variable "ebs_volume_count" {
  type = number
  default = 3
}

variable "disk_size" {
  type = list(number)
  default = [ 4, 5, 6 ]
}

variable "ec2_device_names" {
  type = list(any)
  default = [
    "/dev/xvdb",
    "/dev/xvdc",
    "/dev/xvdd"
  ]
}

resource "aws_instance" "web" {
  ami = data.aws_ami.web.id
  instance_type = "t2.micro"
  tags = local.common_tags
}

resource "aws_ebs_volume" "ebs_volume" {
  count             = var.ebs_volume_count
  availability_zone = aws_instance.web.availability_zone
  size              = var.disk_size[count.index]
}

resource "aws_volume_attachment" "volume_attachement" {
  count       = var.ebs_volume_count
  volume_id   = aws_ebs_volume.ebs_volume.*.id[count.index]
  device_name = var.ec2_device_names[count.index%var.ebs_volume_count]
  instance_id = aws_instance.web.id
}