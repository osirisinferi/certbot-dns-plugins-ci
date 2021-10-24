#!/bin/sh -l

export PORTDIR_OVERLAY="."
export ACCEPT_KEYWORDS="~amd64"
export FEATURES="-ipc-sandbox -network-sandbox"

echo "Working dir: $(pwd)"

mkdir -p $(pwd)/var/cache/{binpkgs,distfiles}

export PKGDIR="$(pwd)/var/cache/binpkgs"
export DISTDIR="$(pwd)/var/cache/distfiles"

find /var/cache/binpkgs
find /var/cache/distfiles

find var/cache/binpkgs
find var/cache/distfiles

emerge -qvbk app-portage/gentoolkit

emerge -qvbk --buildpkg-exclude "*/*::certbot-dns-plugins" \
	app-crypt/certbot-dns-cloudflare \
	app-crypt/certbot-dns-cloudxns \
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

find /var/cache/binpkgs
find /var/cache/distfiles

find var/cache/binpkgs
find var/cache/distfiles

eclean packages
packages_status=$?

eclean distfiles
distfiles_status=$?

find /var/cache/binpkgs
find /var/cache/distfiles

find var/cache/binpkgs
find var/cache/distfiles

status=$(expr $emerge_status + $packages_status + $distfiles_status)
[ $status -eq 0 ] && exit 0 || exit 1

