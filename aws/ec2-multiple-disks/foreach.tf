provider "aws" {
  region = "us-east-2"
}

data "aws_ami" "web" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

variable "disks" {
  type = map(string)
  default = {
    "/dev/xvdb" = "5",
    "/dev/xvdc"  = "6"
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.web.id
  instance_type = "t2.micro"
  tags = {
    Name = "web"
  }
}

resource "aws_ebs_volume" "ebs_volume" {
  for_each = var.disks
  availability_zone = aws_instance.web.availability_zone
  size              = each.value
}

resource "aws_volume_attachment" "volume_attachement" {
  for_each = var.disks
  volume_id   = aws_ebs_volume.ebs_volume[each.key].id
  device_name = each.key
  instance_id = aws_instance.web.id
}
