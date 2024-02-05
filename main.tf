resource "aws_vpc" "new_proj" {
  cidr_block = var.aws_vpc

  tags = {
    Name = "newvpc"
  }
}
