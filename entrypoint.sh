#!/bin/sh -l

export PORTDIR_OVERLAY="../certbot-dns-plugins-overlay/"
export ACCEPT_KEYWORDS="~amd64"
export FEATURES="-ipc-sandbox -network-sandbox"

find /var/cache/binpkgs
find /var/cache/distfiles

emerge -qvbk app-portage/gentoolkit

emerge -qvbk --buildpkg-exclude "*/*::certbot-dns-plugins" \
	app-crypt/certbot-dns-cloudflare \
	app-crypt/certbot-dns-cloudxn \
	app-crypt/certbot-dns-digitalocean \
	app-crypt/certbot-dns-dnsimple \
	app-crypt/certbot-dns-dnsmadeeasy \
	app-crypt/certbot-dns-gehirn \
	app-crypt/certbot-dns-google \
	app-crypt/certbot-dns-linode \
	app-crypt/certbot-dns-luadns \
	app-crypt/certbot-dns-ovh \
	app-crypt/certbot-dns-rfc2136 \
	app-crypt/certbot-dns-route53 \
	app-crypt/certbot-dns-sakuracloud

emerge_status=$?

[ $status -eq 0 ] && exit 0 || exit 1

eclean packages
packages_status=$?

eclean distfiles
distfiles_status=$?

status=$(expr $emerge_status + $packages_status + $distfiles_status)
[ $status -eq 0 ] && exit 0 || exit 1

