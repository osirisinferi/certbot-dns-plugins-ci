#!/bin/sh -l

export PORTDIR_OVERLAY="."
export ACCEPT_KEYWORDS="~amd64"
export FEATURES="-ipc-sandbox -network-sandbox"

find var/cache/

find /var/cache/

emerge --info

emerge -qvbk --buildpkg-exclude "*/*::certbot-dns-plugins" certbot-dns-cloudflare certbot-dns-cloudxns certbot-dns-digitalocean certbot-dns-dnsimple certbot-dns-dnsmadeeasy certbot-dns-gehirn certbot-dns-google certbot-dns-linode certbot-dns-luadns certbot-dns-ovh certbot-dns-rfc2136 certbot-dns-route53 certbot-dns-sakuracloud
