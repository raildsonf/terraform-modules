data "aws_ami" "web" {
  most_recent = true
  owners      = ["${var.ami_owner}"]
  filter {
    name   = "name"
    values = ["${var.ami_name}"]
  }
}

resource "aws_instance" "main" {
  ami           = data.aws_ami.web.id
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = file(var.script_path)
  tags = {
    Name = var.instance_name
  }
}
