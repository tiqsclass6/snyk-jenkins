resource "aws_internet_gateway" "Homework-IGW" {
  vpc_id = aws_vpc.VPC-A-Virginia-Prod.id
  tags = {
    Name    = "Homework-IGW"
    Service = "IGW"
  }
}