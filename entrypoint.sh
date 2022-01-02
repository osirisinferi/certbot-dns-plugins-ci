#!/bin/sh -l

export PORTDIR_OVERLAY="."
export FEATURES="-ipc-sandbox -network-sandbox"

mkdir -p $(pwd)/var/cache/{binpkgs,distfiles}

export PKGDIR="$(pwd)/var/cache/binpkgs"
export DISTDIR="$(pwd)/var/cache/distfiles"

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

eclean packages
packages_status=$?

eclean distfiles
distfiles_status=$?

function check_plugins {
        local -n _loaded_plugins=$1
        local -n _expected_plugins=$2
        IFS=$'\n' local loaded_plugins_sorted=($(sort <<<"${_loaded_plugins[*]}"))
        unset IFS
        IFS=$'\n' local expected_plugins_sorted=($(sort <<<"${_expected_plugins[*]}"))
        unset IFS

        diff=$(diff <(printf "%s\n" "${loaded_plugins_sorted[@]}") <(printf "%s\n" "${expected_plugins_sorted[@]}"))

        if [[ -z "$diff" ]]; then
                echo "All good."
                return 0
        else
                echo "Plugin difference!"
                echo "< loaded plugins vs. > expected plugins:"
                echo ${diff}
                return 1
        fi
}

loaded_plugins=($(certbot plugins 2>&1 | pcregrep -o1 "^\* dns-(.+)"))

expected_plugins=(cloudflare \
cloudxns \
digitalocean \
dnsimple \
dnsmadeeasy \
gehirn \
google \
linode \
luadns \
ovh \
rfc2136 \
route53 \
sakuracloud)

check_plugins loaded_plugins expected_plugins
check_plugins_status=$?

status=$(expr $emerge_status + $packages_status + $distfiles_status + $check_plugins_status)
[ $status -eq 0 ] && exit 0 || exit 1

