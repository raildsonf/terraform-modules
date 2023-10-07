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

resource "aws_instance" "web" {
  ami           = "ami-024e6efaf93d85776"
  instance_type = "t2.micro"
  key_name      = "viper"
  provisioner "local-exec" {
    command = "sleep 120; ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu --private-key ~/.ssh/id_rsa -i '${aws_instance.web.public_ip},' web.yaml"
  }
  tags = {
    Name = "web"
  }
}
