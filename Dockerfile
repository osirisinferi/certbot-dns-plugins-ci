FROM gentoo/portage:latest as portage

FROM gentoo/stage3:amd64-openrc

COPY --from=portage /var/db/repos/gentoo /var/db/repos/gentoo

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

