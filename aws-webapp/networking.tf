
resource "aws_vpc" "tp_vpc" {
  cidr_block = var.cidr_block
}

resource "aws_internet_gateway" "tp_igw" {
  vpc_id = aws_vpc.tp_vpc.id
}

resource "aws_route_table" "tp_rt" {
  vpc_id = aws_vpc.tp_vpc.id
}


resource "aws_route" "tp_gw_route" {
  route_table_id         = aws_vpc.tp_vpc.main_route_table_id
  gateway_id             = aws_internet_gateway.tp_igw.id
  destination_cidr_block = var.public_access_cidr_block
}


resource "aws_subnet" "public_subnets" {
  for_each = { for idx, subnet in var.public_subnets : idx => subnet }

  vpc_id                  = aws_vpc.tp_vpc.id
  cidr_block              = each.value.block
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = {
    Name = each.value.name
  }
}

resource "aws_subnet" "private_subnets" {
  for_each = { for idx, subnet in var.private_subnets : idx => subnet }

  vpc_id            = aws_vpc.tp_vpc.id
  cidr_block        = each.value.block
  availability_zone = each.value.az
  tags = {
    Name = each.value.name
  }
}

resource "aws_eip" "nat_ip" {}


resource "aws_nat_gateway" "tp_nat_gw" {
  subnet_id     = aws_subnet.public_subnets[0].id
  allocation_id = aws_eip.nat_ip.id
  tags = {
    Name = "gw NAT"
  }

  depends_on = [aws_internet_gateway.tp_igw]
}


resource "aws_route" "tp_gw_private_route" {
  route_table_id         = aws_route_table.tp_rt.id
  gateway_id             = aws_nat_gateway.tp_nat_gw.id
  destination_cidr_block = var.public_access_cidr_block
}

resource "aws_route_table_association" "tp_private_rt_assoc" {
  for_each = aws_subnet.private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.tp_rt.id
}

resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow http traffic into VPC"
  vpc_id      = aws_vpc.tp_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "http_sg_ingress" {
  security_group_id = aws_security_group.web_sg.id
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = var.public_access_cidr_block
}

resource "aws_vpc_security_group_egress_rule" "tcp_allow_all_egress" {
  ip_protocol       = "-1"
  cidr_ipv4         = var.public_access_cidr_block
  security_group_id = aws_security_group.web_sg.id
}


resource "aws_security_group" "all_ssh_sg" {
  name        = "all_ssh_sg"
  description = "Allow ssh traffic into VPC"
  vpc_id      = aws_vpc.tp_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "all_ssh_sg_ingress" {
  security_group_id = aws_security_group.all_ssh_sg.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.public_access_cidr_block
}


resource "aws_security_group" "private_ssh_sg" {
  name        = "private_ssh_sg"
  description = "Allow ssh traffic from local cidr"
  vpc_id      = aws_vpc.tp_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "private_ssh_sg_ingress" {
  security_group_id = aws_security_group.private_ssh_sg.id
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.cidr_block
}
