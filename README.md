# corekeeper-dedicatedserver-arm64

본 저장소는 codex (GPT-5.3-codex)를 활용하여 작성하였습니다.

ARM64 환경에서 Core Keeper Dedicated Server를 실행하기 위한 Docker 구성입니다.  
이 저장소는 Box64 위에서 SteamCMD를 구동해 서버 파일을 내려받고, 별도 런타임 이미지로 Core Keeper 전용 서버를 실행하는 흐름을 제공합니다.

## 개요

Core Keeper 전용 서버는 x86_64 기준 배포물이 중심이라 ARM64 환경에서는 그대로 실행하기 어렵습니다.  
이 저장소는 다음 구성을 통해 ARM64 호스트에서 서버를 운영할 수 있게 맞춰져 있습니다.

- `base/`: Box64와 32비트 런타임 라이브러리가 포함된 베이스 이미지
- `steamcmd/`: SteamCMD를 Box64로 실행해 게임 서버 파일과 Steamworks SDK를 내려받는 이미지
- `corekeeper/`: 다운로드된 서버 파일을 실제로 실행하는 이미지
- `run-shell`: 로컬에서 빌드, 다운로드, 실행 흐름을 빠르게 재현하기 위한 예시 스크립트

## 디렉터리 구조

```text
.
├── base
│   └── Dockerfile
├── steamcmd
│   ├── Dockerfile
│   └── entrypoint-steamcmd.sh
├── corekeeper
│   ├── Dockerfile
│   └── entrypoint-corekeeper.sh
└── run-shell
```

## 동작 방식

1. `base` 이미지에서 Box64와 필요한 32비트 라이브러리를 준비합니다.
2. `steamcmd` 이미지에서 SteamCMD를 설치하고 Box64로 실행할 수 있게 래퍼를 구성합니다.
3. SteamCMD로 Core Keeper Dedicated Server와 Steamworks SDK Redist 파일을 내려받습니다.
4. `corekeeper` 이미지가 `_launch.sh`를 실행하기 전에 SDK 경로, 로그 출력, Xvfb 설정을 보정합니다.

## 요구 사항

- ARM64 Linux 또는 ARM64 Linux 컨테이너를 실행할 수 있는 환경
- Docker
- 서버 파일과 SDK를 보관할 영속 볼륨 또는 호스트 디렉터리

## 이미지 빌드

```bash
docker build -f base/Dockerfile -t epko-base:latest base
docker build -f steamcmd/Dockerfile -t epko-steamcmd:latest steamcmd
docker build -f corekeeper/Dockerfile -t epko-corekeeper:latest corekeeper
```

## 서버 파일 다운로드

먼저 SteamCMD 컨테이너를 띄운 뒤 Core Keeper 서버 파일과 Steamworks SDK를 내려받습니다.

```bash
docker run -d -it \
  --name epko-steamcmd \
  -v /path/to/steamcmd-data:/data \
  epko-steamcmd:latest
```

컨테이너 안에서 아래 명령을 실행합니다.

```bash
steamcmd +force_install_dir /data/corekeeper +login anonymous +app_update 1963720 validate +quit
steamcmd +force_install_dir /data/sdk +login anonymous +app_update 1007 validate +quit
```

## 서버 실행

다운로드된 데이터를 마운트해 Core Keeper 서버를 실행합니다.

```bash
docker run -d -it \
  --name epko-corekeeper \
  -v /path/to/steamcmd-data/corekeeper:/home/steam \
  -v /path/to/steamcmd-data/sdk:/home/steam/sdk \
  -p 27015:27015/udp \
  -p 27016:27016/udp \
  epko-corekeeper:latest \
  ./_launch.sh
```

## 스크립트 참고

`run-shell`은 위 과정을 한 번에 재현하기 위한 개인용 예시 스크립트입니다.  
호스트 경로가 하드코딩되어 있으므로 그대로 쓰기보다는 환경에 맞게 수정해서 사용하는 편이 안전합니다.

## 모니터링

`watchcore-python` 저장소를 함께 사용하면 Core Keeper 서버 상태를 간단하게 모니터링할 수 있습니다.  
운영 환경에서는 서버 프로세스 감시와 로그 기반 상태 알림을 별도 저장소로 분리하는 방식이 관리하기 편합니다.

## 참고 사항

- 컨테이너 내부 SteamCMD 설치 경로는 `/home/steam/steamcmd`를 유지합니다.
- `corekeeper/entrypoint-corekeeper.sh`는 `_launch.sh`를 실행하기 전에 SDK 경로와 로그 출력을 보정합니다.
- Xvfb가 서버 실행 스크립트 내부에서 켜지지 않는 경우 엔트리포인트에서 자동으로 띄우도록 되어 있습니다.
