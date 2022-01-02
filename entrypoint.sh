#!/bin/sh -l

export PORTDIR_OVERLAY="."
export FEATURES="-ipc-sandbox -network-sandbox"

mkdir -p $(pwd)/var/cache/{binpkgs,distfiles}

export PKGDIR="$(pwd)/var/cache/binpkgs"
export DISTDIR="$(pwd)/var/cache/distfiles"

emerge -qvbk app-portage/gentoolkit

plugins_full=($(equery -q list -o -F '=$cpv' "certbot-dns-*"))

emerge_status=0

for plugin in "${plugins_full[@]}"
do
        emerge -qvbk --buildpkg-exclude "*/*::certbot-dns-plugins */*::third-party-certbot-dns-plugins" ${plugin}
        emerge_status=$?
        if [ ${emerge_status} -ne 0 ]; then
                break
        fi
done

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

expected_plugins=($(equery -q list -o -F '$name' "certbot-dns-*" | sort -u | sed 's/certbot-dns-//'))

check_plugins loaded_plugins expected_plugins
check_plugins_status=$?

status=$(expr $emerge_status + $packages_status + $distfiles_status + $check_plugins_status)
[ $status -eq 0 ] && exit 0 || exit 1

