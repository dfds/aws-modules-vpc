resource "aws_vpc" "this" {
  cidr_block       = var.cidr_block
  enable_dns_hostnames = true
  tags = merge(var.additional_tags,{
    Name = var.name
  })
}

resource "aws_subnet" "public" {
  count = length(var.cidr_block_public_subnet)
  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${var.cidr_block_public_subnet[count.index]}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name}-public-subnet-${data.aws_availability_zones.available.names[0]}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.cidr_block_private_subnet)
  vpc_id            = "${aws_vpc.this.id}"
  cidr_block        = "${var.cidr_block_private_subnet[count.index]}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.name}-private-subnet-${data.aws_availability_zones.available.names[0]}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = "${aws_vpc.this.id}"
  tags = {
    Name = "${var.name}-igw"
  }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.this.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.this.id
    }
    tags = {
        Name = "${var.name}-public-rt"
    }
}
resource "aws_route_table_association" "public" {
    count = length(var.cidr_block_public_subnet)
    subnet_id = aws_subnet.public[count.index].id
    route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "nated" {
  count = length(var.cidr_block_public_subnet)
  vpc_id     = aws_vpc.this.id
  cidr_block = cidrsubnet(aws_vpc.this.cidr_block[count.index], 8, 3)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.name}-nated-subnet-${data.aws_availability_zones.available.names[count.index]}"
  }
}

resource "aws_eip" "nat_gw_eip_1" {
 count = length(var.cidr_block_public_subnet)
  vpc = true
}

resource "aws_nat_gateway" "gw" {
  count = length(var.cidr_block_public_subnet)
  allocation_id = aws_eip.nat_gw_eip_1.id
  subnet_id     = aws_subnet.public_1.id
}

resource "aws_route_table" "nated_1" {
    vpc_id = aws_vpc.this.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.gw_1.id
    }
    tags = {
        Name = "${var.name}-nated-rt-1"
    }
}
resource "aws_route_table" "nated_2" {
    vpc_id = aws_vpc.this.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.gw_2.id
    }
    tags = {
        Name = "${var.name}-nated-rt-2"
    }
}
resource "aws_route_table" "nated_3" {
    vpc_id = aws_vpc.open_search.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.gw_3.id
    }
    tags = {
        Name = "${var.name}-nated-rt-3"
    }
}
resource "aws_route_table_association" "nated_1" {
    subnet_id = aws_subnet.nated_1.id
    route_table_id = aws_route_table.nated_1.id
}
resource "aws_route_table_association" "nated_2" {
    subnet_id = aws_subnet.nated_2.id
    route_table_id = aws_route_table.nated_2.id
}
resource "aws_route_table_association" "nated_3" {
    subnet_id = aws_subnet.nated_3.id
    route_table_id = aws_route_table.nated_3.id
}
