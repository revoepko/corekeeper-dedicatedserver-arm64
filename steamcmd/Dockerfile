FROM epko-base:latest
USER root

# 상위 저장소 폴더명은 epko-steamcmd지만, 컨테이너 내부 설치 경로는 SteamCMD 고유 경로를 유지합니다.
WORKDIR /home/steam/steamcmd
RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf - \
    && chown -R steam:steam /home/steam/steamcmd

COPY --chmod=755 entrypoint-steamcmd.sh /usr/local/bin/entrypoint.sh

RUN echo '#!/bin/bash\nbox64 /home/steam/steamcmd/linux32/steamcmd "$@"' > /usr/local/bin/steamcmd \
    && chmod +x /usr/local/bin/steamcmd

USER steam
WORKDIR /home/steam
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
