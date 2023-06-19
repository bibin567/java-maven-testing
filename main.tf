provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "ec2_instance" {
  ami           = "ami-022e1a32d3f742bd8"
  instance_type = "t2.micro"
  key_name      = "bibinaws123"

  tags = {
    Name = "My EC2 Instance"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y httpd git",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd",
      "echo '${file("${path.module}/key.pem")}' > key.pem",
      "sudo chmod 400 key.pem",
      "sudo git clone https://github.com/bibin567/project.git /var/www/html"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("${path.module}/key.pem")
      host        = self.public_ip
    }
  }
}



resource "aws_security_group" "ec2_security_group" {
  name        = "my-SG"
  description = "Allow inbound SSH and HTTP traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
