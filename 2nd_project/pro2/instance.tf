data "aws_ami" "pro2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

#####################LOCAL-EC2############################

resource "aws_instance" "local-ec2" {
  ami           = data.aws_ami.pro2.id
  instance_type = var.instance_type[0]
  key_name               = aws_key_pair.my-key.id
  vpc_security_group_ids = [aws_security_group.remote-sg.id]
  

  provisioner "local-exec" {
    command = "echo ${aws_instance.local-ec2.public_ip} >> public_ips.txt"
  }

  tags = {
    "Name" = element(var.tags, 0)
  }
}

#######################REMOTE-EC2############################

resource "aws_key_pair" "my-key" {
  key_name   = "pro-key"
  public_key = file("${path.module}/my_public_key.txt")
}

resource "aws_instance" "remote-ec2" {
  ami                    = data.aws_ami.pro2.id
  instance_type          = var.instance_type[0]
  key_name               = aws_key_pair.my-key.id
  vpc_security_group_ids = [aws_security_group.remote-sg.id]
   tags = {
    "Name" = element(var.tags, 1)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y httpd",
      "cd /var/www/html",
      "sudo wget https://devops14-mini-project.s3.amazonaws.com/default/index-default.html",
      "sudo wget https://devops14-mini-project.s3.amazonaws.com/default/mycar.jpeg",
      "sudo mv index-default.html index.html",
      "sudo systemctl enable httpd --now"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("./private_key.pem")
      host        = self.public_ip
    }

  }
}