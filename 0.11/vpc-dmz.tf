resource "aws_subnet" "public_a" {
  vpc_id            = "${aws_vpc.default.id}"
  availability_zone = "${var.aws_region}a"
  cidr_block        = "${var.aws_vpc_public_subnet_cidr_a}"
}

resource "aws_subnet" "public_b" {
  vpc_id            = "${aws_vpc.default.id}"
  availability_zone = "${var.aws_region}b"
  cidr_block        = "${var.aws_vpc_public_subnet_cidr_b}"
}

resource "aws_subnet" "public_c" {
  vpc_id            = "${aws_vpc.default.id}"
  availability_zone = "${var.aws_region}c"
  cidr_block        = "${var.aws_vpc_public_subnet_cidr_c}"
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = "${aws_subnet.public_a.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = "${aws_subnet.public_b.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}

resource "aws_route_table_association" "public_c" {
  subnet_id      = "${aws_subnet.public_c.id}"
  route_table_id = "${aws_route_table.public_rt.id}"
}

resource "aws_eip" "nat_a" {
  vpc = true
}

resource "aws_eip" "nat_b" {
  vpc = true
}

resource "aws_eip" "nat_c" {
  vpc = true
}

resource "aws_nat_gateway" "nat_a" {
  allocation_id = "${aws_eip.nat_a.id}"
  subnet_id     = "${aws_subnet.public_a.id}"
  depends_on    = ["aws_internet_gateway.gw"]
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = "${aws_eip.nat_b.id}"
  subnet_id     = "${aws_subnet.public_b.id}"
  depends_on    = ["aws_internet_gateway.gw"]
}

resource "aws_nat_gateway" "nat_c" {
  allocation_id = "${aws_eip.nat_c.id}"
  subnet_id     = "${aws_subnet.public_c.id}"
  depends_on    = ["aws_internet_gateway.gw"]
}
