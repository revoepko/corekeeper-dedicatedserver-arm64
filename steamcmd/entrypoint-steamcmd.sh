#!/bin/bash
# 1. 환경 변수 (Box64 필수 설정)
export LD_LIBRARY_PATH=/home/steam/steamcmd/linux32:/usr/lib/i386-linux-gnu:$LD_LIBRARY_PATH
export BOX64_LD_LIBRARY_PATH=/home/steam/steamcmd/linux32:/usr/lib/i386-linux-gnu
export BOX64_DYNAREC_STRONGMEM=1
export BOX64_WAITLSB=1
export BOX64_LOG=0  # 로그 노이즈 감소

# 2. 실행 로직
if [ "$#" -eq 0 ]; then
    exec /bin/bash # 인자가 없으면 bash 실행
fi

if [[ "$1" == *"steamcmd"* ]]; then
    STEAM_BIN="/home/steam/steamcmd/linux32/steamcmd"
    shift
    exec box64 "$STEAM_BIN" "$@"
else
    exec "$@"
fi
