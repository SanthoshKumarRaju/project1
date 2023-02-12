resource "aws_security_group" "rds" {
  name        = "allow rds"
  description = "Allow rds inbound traffic"
  vpc_id      = aws_vpc.vpc-app.id

  ingress {
    description     = "bastion to rds"
    from_port       = 3369
    to_port         = 3369
    protocol        = "tcp"
    security_groups = [aws_security_group.app-sg.id]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(
    {
      Name        = "Rds-sg"
    },
  )
  depends_on = [
    aws_security_group.app-sg,
  ]
}

#group
resource "aws_db_subnet_group" "data" {
  name       = "mysql"
  subnet_ids = [for subnet in aws_subnet.private-subnet[0] : subnet.id]

  tags = {
    Name = "RDS-sg"
  }
}

resource "aws_db_instance" "mysql" {
  allocated_storage       = 50
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = "db.t3.micro"
  db_name                    = "mydb"
  username                = "admin"
  password                = "santhosh"
  parameter_group_name    = "default.mysql5.7"
  skip_final_snapshot     = true
  backup_retention_period = 7
  availability_zone = data.aws_availability_zones.available.names[0]
  kms_key_id = aws_kms_key.kms-key.arn
  storage_encrypted ="true"
  vpc_security_group_ids      = aws_security_group.rds[*].id
  db_subnet_group_name        = "mysql"

    tags ={
      Name        = "rds"

    }
  
}