resource "aws_security_group" "app-sg" {
  name        = "app-sg"
  description = "application-sg"
  vpc_id      = aws_vpc.vpc-app.id

  ingress {
    description     = "admin"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks = ["49.205.33.59/32"]
  }

  ingress {
    description     = "httpd"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
   tags = {
    Name = "app-sg"
    terraform = "true"
  }
}

resource "aws_instance" "app-ec2" {
  ami                         = "ami-06489866022e12a14"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.app-sg.id]
  subnet_id                   = aws_subnet.private-subnet[0].id
  key_name = aws_key_pair.ec2-application.id
    root_block_device {
    encrypted = true
    volume_type = "gp2"
    kms_key_id  = aws_kms_key.kms-key.id
  }


   tags = {
    Name = "app-ec2"
    terraform = "true"
  }
}