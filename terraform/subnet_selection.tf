# Select a specific subnet in a supported AZ (us-east-1a)
data "aws_subnet" "selected" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = "us-east-1a"
}
