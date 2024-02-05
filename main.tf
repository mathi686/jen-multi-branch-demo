resource "aws_vpc" "new_proj" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "newvpc"
  }  
}
