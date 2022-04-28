/////////////////////////////////////////////////
// CA Key & Self-Signed Certificate(s)
/////////////////////////////////////////////////

resource "tls_private_key" "CA" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "CA" {
  private_key_pem = tls_private_key.CA.private_key_pem
  validity_period_hours = local.ca_cert_validity_hours

  subject {
    common_name  = "insecure-ca-authority.org"
    organization = "Insecure CA Authority"
  }

  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
   ]
}

/////////////////////////////////////////////////
// Key(s) & certificate request(s)
/////////////////////////////////////////////////

resource "tls_private_key" "MAIN" {
  for_each = local.domains
  
  algorithm   = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_cert_request" "MAIN" {
  for_each = local.domains
  
  private_key_pem = tls_private_key.MAIN[each.key].private_key_pem

  subject {
    common_name  = format("%s",each.key)
    organization = format("%s Domain",each.key)
  }

  dns_names = [
    format("%s",each.key),
    format("*.%s",each.key),
  ]
}

/////////////////////////////////////////////////
// Signed Certificates
/////////////////////////////////////////////////

resource "tls_locally_signed_cert" "MAIN" {
  for_each = local.domains

  validity_period_hours = local.cert_validity_period_hours
  cert_request_pem   = tls_cert_request.MAIN[each.key].cert_request_pem
  ca_private_key_pem = tls_private_key.CA.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.CA.cert_pem

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}
