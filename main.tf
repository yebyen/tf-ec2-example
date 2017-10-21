provider "aws" { }
resource "aws_key_pair" "yebyen" {
  key_name   = "yebyen-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDib2Mn2TVPncZW9iivWH13ZkTIMUaKPhJQp7QFYrTZtnoCiaq9pINgmW6LoGEcNdLBctOH3/aDVW3Js+AGjwJJns0/rR/G9TCL/DcFCpWH5FmOgt5KRXU+IPmNKbbxMuGXJH2khWI+crX8QkTaFPZpAeugHdVgCuK4rcblWDDnqX7McH4tgEAt/Oe+iTPEwk3DtosRKl79p6FIUo0JMQYMYErgae6e1c4n/h1Pg8EPCfGdaVcqeIfHoEisJHUKHPsmQ3JUf2LQyEM5K4/Kx4YH+Xz3KrI/2Bs7CXq+8/aw0jlnnSmgQ13VUdhp1wNpOErWAhTtcV1DF9TeqDgsbjEX kingdonb@kbarret8-mbpro-2014.dhcp.nd.edu"
}
resource "aws_instance" "example" {
  ami = "ami-2d39803a"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  key_name = "yebyen-key"
  subnet_id = "subnet-fac1dba0"

  user_data = <<-EOF
              #!/bin/bash -x
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.server_port}" &
              EOF

  tags {
    Name = "terraform-example"
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  vpc_id = "vpc-8fcc11f7"
  # TCP access
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTP access
  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}
variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default = 8080
}
output "public_ip" {
  value = "${aws_instance.example.public_ip}"
}
