#!/bin/sh -l

PORTDIR_OVERLAY="." ACCEPT_KEYWORDS="~amd64" emerge -qv certbot-dns-cloudflare certbot-dns-cloudxns certbot-dns-digitalocean certbot-dns-dnsimple certbot-dns-dnsmadeeasy certbot-dns-gehirn certbot-dns-google certbot-dns-linode certbot-dns-luadns certbot-dns-ovh certbot-dns-rfc2136 certbot-dns-route53 certbot-dns-sakuracloud
