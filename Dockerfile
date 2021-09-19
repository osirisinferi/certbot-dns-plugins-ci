FROM gentoo/portage:latest as portage

FROM gentoo/stage3:amd64-openrc

COPY --from=portage /usr/portage /usr/portage

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

