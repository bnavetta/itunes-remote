#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

DOMAIN="gandalf.local"
IP="172.23.42.65"

certstrap --depot-path certs init --common-name CertAuth
certstrap --depot-path certs request-cert --ip "$IP" --domain "$DOMAIN"
certstrap --depot-path certs sign "$DOMAIN" --CA CertAuth 
