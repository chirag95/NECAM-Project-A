output "admin_ssh_key_public" {
  description = "The generated public key data in PEM format"
  value       = tls_private_key.rsa.public_key_openssh
}

output "admin_ssh_key_private" {
  description = "The generated private key data in PEM format"
  sensitive   = true
  value       = tls_private_key.rsa.private_key_pem
}