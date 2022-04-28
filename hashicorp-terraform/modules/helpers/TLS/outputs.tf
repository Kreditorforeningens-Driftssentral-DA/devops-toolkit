output "SIGNED_CERTIFICATES" {
  sensitive = false
  value = [
    for domain in local.domains: {
      format("%s",domain) = chomp(join("",[
        tls_locally_signed_cert.MAIN[domain].cert_pem,
        tls_self_signed_cert.CA.cert_pem,
      ]))
    }
  ]
}

output "CERTIFICATES_PRIVATE_KEYS" {
  sensitive = true
  value = [
    for domain in local.domains: {
      format("%s",domain) = tls_private_key.MAIN[domain].private_key_pem
    }
  ]
}
