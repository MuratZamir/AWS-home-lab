#configure aws provider with proper credentials
provider "aws" {
  region     = "ENTER_REGION"
  access_key = "PATH_TO_ACCESS_KEY"
  secret_key = "PATH_TO_SECRET_KEY"
}



# create VPC 
resource "aws_vpc" "vpc-project" {
  cidr_block = "ASSIGN_IPv4_CIDR_BLOCK"
  tags = {
    Name = "vpc"
  }

}


# create Internet Gateway
resource "aws_internet_gateway" "gateway-project" {
  vpc_id = aws_vpc.vpc-project.id  # make sure vpc_ic matches the vpc name 

  tags = {
    Name = "gateway"
  }
}


# create custom Route Table
resource "aws_route_table" "route-table-project" {
  vpc_id = aws_vpc.vpc-project.id

  route {
    cidr_block = "0.0.0.0/0"  # gives every IP address on internet an access
    gateway_id = aws_internet_gateway.gateway-project.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gateway-project.id
  }

  tags = {
    Name = "route-table"
  }
}


# create a Subnet 
resource "aws_subnet" "subnet-project" {
  vpc_id            = aws_vpc.vpc-project.id
  cidr_block        = "ENTER_IPv4_CIDR_BLOCK_FOR_SUBNET"
  availability_zone = "ENTER_REGION"  # region must match 

  tags = {
    Name = "subnet"
  }
}


# associate subnet with route table
resource "aws_route_table_association" "association-subnt-routetbl" {
  subnet_id      = aws_subnet.subnet-project.id
  route_table_id = aws_route_table.route-table-project.id

}


# create a security group to allow port 22,80,443
resource "aws_security_group" "allow-web-traffic" {
  name        = "web-traffic"
  description = "Allow Web Traffic"
  vpc_id      = aws_vpc.vpc-project.id

  # for HTTPS connection
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # for HTTP connection
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # for SSH connection
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # can add more port forwarding protocols by specifying other ports to be allowed

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"  # means any protocol
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow-web-traffic"
  }
}


# create network interface with ip in the subnet 
resource "aws_network_interface" "webserver-nic" {
  subnet_id       = aws_subnet.subnet-project.id
  private_ips     = ["ASSING_PRIVATE_IP_FOR_NIC"]
  security_groups = [aws_security_group.allow-web-traffic.id]

  tags = {
    Name = "NIC"
  }

}


# create elastic IP and assign to NIC
resource "aws_eip" "elastic-ip" {
  vpc                       = true
  network_interface         = aws_network_interface.webserver-nic.id
  associate_with_private_ip = "ASSING_PRIVATE_IP_FOR_NIC"
  depends_on                = [aws_internet_gateway.gateway-project]

  tags = {
    Name = "elastic-ip"
  }
}



# create ec2 instance with Ubuntu apache2 webserver 
resource "aws_instance" "ubuntu-webserver" {
  ami               = "AMI_FOR_EC2_INSTANCE"  # Ubuntu ami: ami-02f3416038bdb17fb
  instance_type     = "t2.micro"
  availability_zone = "ENTER_REGION" # make sure it is the same as your subnet
  key_name          = "KEYPAIR"    # make sure it is the same as your keypair name

  network_interface {
    device_index         = 0  # default
    network_interface_id = aws_network_interface.webserver-nic.id
  }

  user_data = <<-EOF
            #!/bin/bash
            sudo apt update -y
            sudo apt install apache2 -y
            sudo systemctl start apache2
            sudo bash -c 'echo Apache2 Web Server Hosted > /var/www/html/index.html'
            EOF

        # EOF gives the ability to write inline code
        # starts the apache2 service by hosting a website through IPv4 address 

  tags = {
    Name = "apache-webserver"
  }

}



