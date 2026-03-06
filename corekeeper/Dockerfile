FROM epko-base:latest
USER root

COPY --chmod=755 entrypoint-corekeeper.sh /usr/local/bin/entrypoint.sh

USER steam
WORKDIR /home/steam
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
