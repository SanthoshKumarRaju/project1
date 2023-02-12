resource "aws_key_pair" "ec2-application" {
  key_name   = "application-key"
  public_key = tls_private_key.file-type.public_key_openssh
  }

resource "tls_private_key" "file-type" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "apllication-key" {
  content  = tls_private_key.file-type.public_key_pem
  filename = "apllication-key"
}