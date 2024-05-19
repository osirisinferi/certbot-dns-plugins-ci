#!/bin/sh -l

export PORTDIR_OVERLAY="."
export FEATURES="-ipc-sandbox -network-sandbox -pid-sandbox -usersandbox"

mkdir -p $(pwd)/var/cache/{binpkgs,distfiles}

export PKGDIR="$(pwd)/var/cache/binpkgs"
export DISTDIR="$(pwd)/var/cache/distfiles"

mkdir -p "${DISTDIR}/git3-src/"
chown -R portage:portage "${DISTDIR}/git3-src/"

MIN=10
MAX=12

declare -a PY_TARGETS

for i in `seq ${MIN} ${MAX}`
do
        PY_TARGETS+=("python3."${i})
done

function check_plugins {
        local -n _loaded_plugins=$1
        local -n _expected_plugins=$2
        IFS=$'\n' local loaded_plugins_sorted=($(sort <<<"${_loaded_plugins[*]}"))
        unset IFS
        IFS=$'\n' local expected_plugins_sorted=($(sort <<<"${_expected_plugins[*]}"))
        unset IFS

        diff=$(diff <(printf "%s\n" "${loaded_plugins_sorted[@]}") <(printf "%s\n" "${expected_plugins_sorted[@]}"))

        echo -n "Checking if all currently installed plugins are available in Certbot: "

        if [[ -z "$diff" ]]; then
                echo -e "all installed plugins available.\n"
                return 0
        else
                echo "plugin difference!"
                echo "< loaded plugins vs. > installed plugins:"
                echo ${diff}
                return 1
        fi
}

# The Portage Docker image is synced just once a week. Let's sync it to the most recent version.
emaint sync -a >/dev/null

emerge -qvbk app-portage/gentoolkit

USE="-*" emerge -qvbk dev-libs/libpcre

plugins_available=($(equery -q list -o -F '=$cpv' "certbot-*"))
plugins_available_len=${#plugins_available[@]}
plugins_installed=()

emerge_status=0
check_plugins_status=0

for i in "${!plugins_available[@]}"
do
        plugin=${plugins_available[${i}]}
        printf 'Installing %s (%d/%d)\n' ${plugin} $((${i}+1)) ${plugins_available_len} 

        emerge -qvbk --buildpkg-exclude "*/*::certbot-dns-plugins */*::third-party-certbot-dns-plugins dev-lang/rust-bin" ${plugin}
        emerge_status=$?
        if [ ${emerge_status} -ne 0 ]; then
                break
        fi

        plugin_stripped=$(stripversion.py "${plugin}" | sed 's/certbot-//')

        if [[ ! " ${plugins_installed[*]} " =~ " ${plugin_stripped} " ]]; then
                plugins_installed+=($plugin_stripped)
        fi


        for py in ${PY_TARGETS[@]}; do
                echo "Testing ${py^}:"
                plugins_loaded=($(${py} /usr/bin/certbot plugins 2>&1 | pcregrep -o1 "^\* (.+)" | pcregrep -v "^apache$|^nginx$|^standalone$|^webroot$"))
		plugins_loaded_status=$?

		if [ ${plugins_loaded_status} -ne 0 ]; then
			echo "This didn't work:"
			$(${py} /usr/bin/certbot plugins)
		fi

                check_plugins plugins_loaded plugins_installed
                check_plugins_status=$?

                if [ ${check_plugins_status} -ne 0 ]; then
                        $(${py} certbot plugins -vvv)
                        break 2
                fi
        done
done

eclean packages
packages_status=$?

eclean distfiles
distfiles_status=$?

status=$(expr $emerge_status + $packages_status + $distfiles_status + $check_plugins_status)
[ $status -eq 0 ] && exit 0 || exit 1

