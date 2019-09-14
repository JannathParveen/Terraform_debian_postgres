
  # Our Security group to allow HTTP and SSH access
  # vpc_security_group_ids = ["${aws_security_group.default.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  # subnet_id = "${aws_subnet.default.id}"

  resource "aws_vpc" "default" {
    cidr_block = "190.10.0.0/16"
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
    Name = "VPC_Default_Terraform"
    }
  }

  # Create an internet gateway to give our subnet access to the outside world
  resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"
  }

  # Grant the VPC internet access on its main route table
  resource "aws_route" "internet_access" {
    #vpc_id = "${aws_vpc.default.id}"
    route_table_id         = "${aws_vpc.default.main_route_table_id}"
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = "${aws_internet_gateway.default.id}"

    #route {
    #ipv6_cidr_block = "0.0.0.0/0"
    #gateway_id             = "${aws_internet_gateway.default.id}"
    #}

    #route {
    #ipv6_cidr_block = "::/0"
    #gateway_id             = "${aws_internet_gateway.default.id}"
    #}
  }

  # Create a subnet to launch our instances into
  resource "aws_subnet" "subnet1" {
    vpc_id                  = "${aws_vpc.default.id}"
    cidr_block              = "190.10.1.0/24"
    map_public_ip_on_launch = true
  }

  resource "aws_route_table_association" "a" {
    subnet_id      = "${aws_subnet.subnet1.id}"
    route_table_id = "${aws_vpc.default.main_route_table_id}"
  }

  # A security group for the ELB so it is accessible via the web
  resource "aws_security_group" "elb" {
    name        = "terraform_example_elb"
    description = "Used in the terraform"
    vpc_id      = "${aws_vpc.default.id}"

    # HTTP access from anywhere
    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    # outbound internet access
    egress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  resource "aws_elb" "web" {
    name = "Debian-elb"

    subnets         = ["${aws_subnet.subnet1.id}"]
    security_groups = ["${aws_security_group.elb.id}"]
    #instances       = ["${aws_instance.debian.id[count.index]}"]
    #instances = "${aws_instance.debian[index].id}"

    # aws_instance.debian[0]
    #instances = ["${aws_instance.debian.*.id}"]

    #instances = "${element(aws_instance.debian.*.id, count.index)}"

    #instances = "${aws_eip.test.instance}"
        depends_on = ["data.aws_instance.debian"]
    instances =  "${data.aws_instances.Debians.ids}"


    listener {
      instance_port     = 80
      instance_protocol = "http"
      lb_port           = 80
      lb_protocol       = "http"
    }

    health_check {
      healthy_threshold = 2
      unhealthy_threshold = 2
      timeout = 3
      target = "HTTP:80/"
      interval = 30
    }
  }

  data "aws_instances" "Debians" {

    instance_tags = {
      Name = "Debian 9 nginx"
    }

    filter {
      name = "tag:Name"
      # name = "Debian 9 nginx"
      # values accept list of values which includes null
      values = ["Debian 9 nginx","doesnotexist"]
    }

    instance_state_names = ["running", "stopped"]
    depends_on = ["data.aws_instance.debian"]
  }

  #resource "aws_elb_attachment" "web" {
  #	count = "${var.instance_count}"
  #	elb      = "${aws_elb.web.id}"
  #	instance = "${element(aws_instance.debian.*, count.index)}"
  #}

  resource "aws_instance" "debian" {

    count         = "${var.instance_count}"
    #ami           = "${var.ami_id}"
    ami           = "${lookup(var.ami_id,var.aws_region)}"
    instance_type = "${var.instance_type}"
    # availability_zone = "${var.aws_region}+a"
    subnet_id  = "${aws_subnet.subnet1.id}"

    tags = {
       Name = "${var.name}"
      # Name  = "Terraform-${count.index + 1}"
    }

    vpc_security_group_ids = [
      "${aws_security_group.http-group.id}",
      "${aws_security_group.https-group.id}",
      "${aws_security_group.ssh-group.id}",
      "${aws_security_group.all-outbound-traffic.id}",
    ]


    #  connection {
    #  type        = "ssh"
    #  agent       = false
    #  private_key = "${file("./MyKeyPair.pem")}"
    #  user        = "root"
    #  host        = self.public_ip
    #  }

    # connection {
    # The default username for our AMI
    #  user = "ubuntu"
    #  password = "${random_string.password.result}"
    #  host = self.public_ip
    #  private_key = "${file(var.public_key_path)}"

    # The connection will use the local SSH agent for authentication.
    #}

    # user_data = <<EOF
    # !/bin/bash
    # sudo apt-get -y update
    # sudo apt-get -y install nginx
    # sudo service nginx start
    # EOF

    user_data = "${file("install_nginx1.sh")}"

    }

    data "aws_instance" "debian" {

      count  = "${var.instance_count}"
      #instance_id = "${aws_instance.debian.id[count.index]}"
      instance_id = "${aws_instance.debian[count.index].id}"

    }

  resource "aws_security_group" "https-group" {
    name = "https-access-group"
    description = "Allow traffic on port 443 (HTTPS)"
    vpc_id      = "${aws_vpc.default.id}"

    tags = {
      Name = "HTTPS Inbound Traffic Security Group"
    }

    ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
    }
  }


  resource "aws_security_group" "http-group" {
    name = "http-access-group"
    description = "Allow traffic on port 80 (HTTP)"
    vpc_id      = "${aws_vpc.default.id}"

    tags = {
      Name = "HTTP Inbound Traffic Security Group"
    }

    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
    }
  }

  resource "aws_security_group" "all-outbound-traffic" {
    name = "all-outbound-traffic-group"
    description = "Allow traffic to leave the AWS instance"
    vpc_id      = "${aws_vpc.default.id}"

    tags = {
      Name = "Outbound Traffic Security Group"
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
    }
  }

  resource "aws_security_group" "ssh-group" {
    name = "ssh-access-group"
    description = "Allow traffic to port 22 (SSH)"
    vpc_id      = "${aws_vpc.default.id}"

    tags = {
      Name = "SSH Access Security Group"
    }

    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = [
        "0.0.0.0/0"
      ]
    }
  }
