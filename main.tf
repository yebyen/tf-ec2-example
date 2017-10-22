provider "aws" { }
resource "aws_key_pair" "mootop" {
  key_name   = "mootop-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCwSARpkC0l+gN5C1i26QPtYqKGsW6UBmP8zp9FdceaX5N1KcoRkyc4QRe0UXb1rajelQIaxd2SCAv63ilFkO5sqV9jryZlfq/QBMHByXbdwMcvr5aDVVSwtXLVg/mRSIeIbwcuphOKkTtykFO0dGiMqBpOmVC9ytDnjFak5+3cgtwGxH62yujokCgMc7AWZRrZqUsl64sOoj+gHjNEDOymiBEjbitnJINPWQy+2QNLkXCD1Y42zDl98DDO7CVMbABfFz/h4ex7suFOXdk2vdYEVWMA16Hk7xd3oiGSZ9Xi7dKXR2ky7L0iPL2ajLxy6vTd7zBKcuD4sY9ihIezfLFX kingdon@mootop"
}
resource "aws_instance" "example" {
  ami = "ami-2d39803a"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.instance.id}"]
  key_name = "mootop-key"
  subnet_id = "${var.subnet_id}"

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
  vpc_id = "${var.vpc_id}"
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
  # SSH access
  ingress {
    from_port = 22
    to_port = 22
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
variable "vpc_id" {
  description = "The VPC to put the t2.micro into"
  default = "vpc-1d29f465"
}
variable "subnet_id" {
  description = "The Public Subnet ID that ports will be exposed on"
  default = "subnet-cab7ad90"
}
output "public_ip" {
  value = "${aws_instance.example.public_ip}"
}
