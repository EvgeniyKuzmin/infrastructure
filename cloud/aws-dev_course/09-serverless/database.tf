locals {
  db_purpose = "${local.app_name}-metadata"
  db_name    = "${var.project_name}-${local.db_purpose}"
  db_tags    = merge(local.tags, {
    "Purpose" = local.db_purpose
  })
}

resource "aws_db_instance" "metadata" {
  allocated_storage      = 5
  availability_zone      = data.aws_availability_zones.available.names[0]
  engine                 = "postgres"
  engine_version         = "14.1"
  instance_class         = "db.t3.micro"
  identifier             = local.db_name
  db_name                = replace(title(replace(local.db_purpose, "-", " ")), " ", "")
  username               = var.db_username
  password               = random_password.db_password.result
  skip_final_snapshot    = true
  publicly_accessible    = true
  apply_immediately      = true
  vpc_security_group_ids = [aws_security_group.metadata_db.id]
  db_subnet_group_name   = aws_db_subnet_group.metadata.name

  tags                   = local.db_tags
}


resource "aws_security_group" "metadata_db" {
  name   = local.db_name
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
      cidr_blocks      = ["${local.my_ip}/32"]
      ipv6_cidr_blocks = []
      from_port        = 5432
      to_port          = 5432
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
  ]
}

resource "aws_db_subnet_group" "metadata" {
  name       = local.db_name
  subnet_ids = [
    aws_subnet.public_a.id,
    aws_subnet.public_b.id,
    aws_subnet.public_c.id,
  ]
}
