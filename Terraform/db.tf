
data "aws_vpc" "select2" {
  filter {
    name = "tag:Name"
    values = ["education-vpc"]
  }
}

output "aws_vpc_id" {
  value = "${data.aws_vpc.select2.id}"
}



data "aws_subnets" "example4" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.select2.id]
  }
  
  tags = {
        Name = "education-vpc-private*"
      }
}


output "aws_sub_ids4" {
  value = data.aws_subnets.example4.ids
}
 

output "db_endpoint" {
value = "${aws_db_instance.db.address}"
}

#-------------------------------------------------------------------------------------RDS


resource "aws_db_subnet_group" "db_sub_g" {
  name        = "db_sub_g"
  
  subnet_ids  = data.aws_subnets.example4.ids 
  tags = {
    Name = "db_priv_sub_g"
  }
}

resource "aws_security_group" "rds_sg" {
  name   = "mysqlallow"
  vpc_id = "${data.aws_vpc.select2.id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    #security_groups = ["aws_security_group.webservers.id"]
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    #security_groups = ["${aws_security_group.webservers.id}"]
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_sg"
  }
}
 
resource "aws_db_instance" "db" {
  identifier             = "db"
  instance_class         = "db.t2.micro"
  storage_type           = "gp2"
  allocated_storage      = 5
  engine                 = "mysql"
  engine_version         = "5.7"
  port                   = 3306
  username               = "root"
  password               = "petclinic"
  db_subnet_group_name   = aws_db_subnet_group.db_sub_g.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = false
  depends_on = [module.eks]
  
}



