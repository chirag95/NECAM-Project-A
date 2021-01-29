resource "tls_private_key" "rsa" {
  algorithm = var.algorithm
  rsa_bits  = var.rsa_bits
}
