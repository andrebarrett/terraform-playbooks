
resource "aws_vpc" "tp_vpc" {
  cidr_block = var.cidr_block
}

resource "aws_internet_gateway" "tp_igw" {
  vpc_id = aws_vpc.tp_vpc.id
}

resource "aws_route_table" "tp_rt" {
  vpc_id = aws_vpc.tp_vpc.id
  count  = 2
}

resource "aws_route" "tp_local_public_route" {
  route_table_id         = aws_route_table.tp_rt[0].id
  destination_cidr_block = var.cidr_block
  gateway_id             = "local"
}

resource "aws_route" "tp_gw_route" {
  route_table_id         = aws_route_table.tp_rt[0].id
  gateway_id             = aws_internet_gateway.tp_igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "tp_public_rt_assoc" {
  gateway_id     = aws_internet_gateway.tp_igw.id
  route_table_id = aws_route_table.tp_rt[0].id
}


resource "aws_subnet" "public_subnets" {
  for_each = { for idx, subnet in var.public_subnets : idx => subnet }

  vpc_id            = aws_vpc.tp_vpc.id
  cidr_block        = each.value.block
  availability_zone = each.value.az
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

resource "aws_route" "tp_local_private_route" {
  route_table_id         = aws_route_table.tp_rt[1].id
  destination_cidr_block = var.cidr_block
  gateway_id             = "local"
}

resource "aws_route" "tp_gw_private_route" {
  route_table_id         = aws_route_table.tp_rt[1].id
  gateway_id             = aws_nat_gateway.tp_nat_gw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "tp_private_rt_assoc" {
  gateway_id     = aws_nat_gateway.tp_nat_gw.id
  route_table_id = aws_route_table.tp_rt[1].id
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
  cidr_ipv4 = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "tcp_allow_all_egress" {
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.web_sg.id
}
