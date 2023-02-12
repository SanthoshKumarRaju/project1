output "AZ" {
    value = data.aws_availability_zones.available.names
  
}
output "vpc-id" {
    value= aws_vpc.vpc-app.id
}
output "igw-id" {
    value = aws_internet_gateway.igw-app.id
}
