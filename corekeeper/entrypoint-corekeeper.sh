#!/bin/bash
# 1. 환경 변수 (서버 실행 최적화)
# 핵심: 게임 바이너리가 있는 폴더와 SDK 폴더를 LD_LIBRARY_PATH에 추가해야 합니다.
export LD_LIBRARY_PATH=/home/steam/linux64:/home/steam/sdk/linux64:/usr/lib/i386-linux-gnu:$LD_LIBRARY_PATH
export BOX64_LD_LIBRARY_PATH=/home/steam/linux64:/home/steam/sdk/linux64:/usr/lib/i386-linux-gnu
export BOX64_DYNAREC_STRONGMEM=1
export BOX64_WAITLSB=1
export BOX64_LOG=0

# 2. _launch.sh 실시간 패치
if [ -f "./_launch.sh" ]; then
    echo "[Patch] Core Keeper 실행 환경 최적화 중..."
    # Rosetta 차단 및 Box64 강제 (중복 box64 실행 방지)
    if grep -q 'box64 box64 "\$exepath"' ./_launch.sh; then
        sed -i 's/box64 box64 "\$exepath"/\/usr\/local\/bin\/box64 "\$exepath"/g' ./_launch.sh
    fi
    # SDK 경로 수정 (마운트된 절대 경로로 고정)
    sed -i 's|Steamworks SDK Redist/linux64|/home/steam/sdk/linux64|g' ./_launch.sh
    # box64 chmod 시도 제거 (이미 /usr/local/bin/box64에 설치됨)
    sed -i 's/^chmod .*box64.*/true # skip box64 chmod/' ./_launch.sh
    # 로그를 stdout으로 강제
    sed -i 's/-logfile CoreKeeperServerLog.txt/-logfile \/dev\/stdout/g' ./_launch.sh
fi

# 3. 가상 디스플레이(Xvfb) 체크
# 만약 _launch.sh 내부에서 Xvfb를 띄우지 않는다면 여기서 띄워줘야 합니다.
if ! grep -q "Xvfb" ./_launch.sh 2>/dev/null; then
    if [ -z "$DISPLAY" ]; then
        export DISPLAY=:99
    fi

    if ! xdpyinfo -display "$DISPLAY" >/dev/null 2>&1; then
        Xvfb "$DISPLAY" -screen 0 1280x720x24 >/tmp/xvfb.log 2>&1 &
    fi
fi

if [ "$#" -eq 0 ]; then
    exec /bin/bash
fi

exec "$@"
