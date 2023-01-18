resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  tags = merge(
    var.additional_tags,
    {
      Name = var.name
    }
  )
}

resource "aws_subnet" "public" {
  count                   = length(var.cidr_block_public_subnet)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.cidr_block_public_subnet[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = merge(
    var.additional_tags,
    {
      Name = "${var.name}-public-subnet-${data.aws_availability_zones.available.names[0]}",
      Tier = "public"
    }
  )
}

resource "aws_subnet" "private" {
  count                   = length(var.cidr_block_private_subnet)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.cidr_block_private_subnet[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = merge(
    var.additional_tags,
    {
      Name = "${var.name}-private-subnet-${data.aws_availability_zones.available.names[0]}",
      Tier = "private"
    }
  )
}

resource "aws_subnet" "data" {
  count             = length(var.cidr_block_data_subnet)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.cidr_block_data_subnet[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    var.additional_tags,
    {
      Name = "${var.name}-data-subnet-${data.aws_availability_zones.available.names[count.index]}"
      Tier = "data"
    }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags = merge(
    var.additional_tags,
    {
      Name = "${var.name}-igw"
    }
  )
}
resource "aws_eip" "this" {
  count = length(var.cidr_block_public_subnet)
  vpc   = true
}
resource "aws_nat_gateway" "this" {
  count         = length(var.cidr_block_public_subnet)
  allocation_id = aws_eip.this[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  depends_on = [aws_internet_gateway.this]
}
resource "aws_route_table" "public" {
  count  = length(var.cidr_block_public_subnet)
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = merge(
    var.additional_tags,
    {
      Name = "${var.name}-public-rt"
    }
  )
}
resource "aws_route_table_association" "public" {
  count          = length(var.cidr_block_public_subnet)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_route_table" "private" {
  count  = length(var.cidr_block_private_subnet)
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
  tags = merge(
    var.additional_tags,
    {
      Name = "${var.name}-public-rt"
    }
  )
}
resource "aws_route_table_association" "private" {
  count          = length(var.cidr_block_private_subnet)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}