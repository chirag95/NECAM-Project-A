variable "algorithm" {
    description = " The name of the algorithm to use for the key. Currently-supported values are RSA and ECDSA."
    default = "RSA"
}

variable "rsa_bits" {
    description = "The size of the generated RSA key in bits"
    default = 4096
}