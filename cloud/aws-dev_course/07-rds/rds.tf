resource "aws_db_instance" "images" {
  allocated_storage   = 5
  availability_zone   = data.aws_availability_zones.available.names[0]
  engine              = "postgres"
  engine_version      = "14.1"
  instance_class      = "db.t3.micro"
  identifier          = "${var.project_name}-${local.app_name}"
  name                = local.app_name
  username            = "evgenii"
  password            = var.db_password
  skip_final_snapshot = true
  publicly_accessible = true
  apply_immediately   = true
  vpc_security_group_ids = [aws_security_group.db_images.id]
  db_subnet_group_name = aws_db_subnet_group.images.name
}


resource "aws_security_group" "db_images" {
  name   = "${var.project_name}-db-postgres-${local.app_name}"
  vpc_id = aws_vpc.this.id
  egress = [
    {
      description      = ""
      protocol         = "all"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      from_port        = 0
      to_port          = 0
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
  ingress = [
    {
      description      = "Used for testing and managing by a developer"
      protocol         = "tcp"
      cidr_blocks      = [var.ingr_ssh_ip]
      ipv6_cidr_blocks = []
      from_port        = 5432
      to_port          = 5432
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = ""
      protocol         = "tcp"
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      from_port        = 5432
      to_port          = 5432
      prefix_list_ids  = []
      security_groups  = [aws_security_group.server.id]
      self             = false
    }
  ]
}

resource "aws_db_subnet_group" "images" {
  name       = "${var.project_name}-db-postgres-images"
  subnet_ids = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id,
    aws_subnet.public_c.id,
  ]
}