#!/usr/bin/env bash

ARIA_NG_VERSION='1.0.3'
ARIA2_TOKEN=$(od -x /dev/urandom | head -1 | awk '{OFS=""; print $2$3,$4,$5,$6,$7$8$9}')
BGMI_TOKEN=$(od -x /dev/urandom | head -1 | awk '{OFS=""; print $2$3,$4,$5,$6,$7$8$9}')
#BGMI_VERSION=dev


TEMPLATE="
CURRENT_UID=`id -u`
CURRENT_GID=`id -g`
ARIA2_TOKEN=${ARIA2_TOKEN}
BGMI_TOKEN=${BGMI_TOKEN}
LOCAL_TZ=Asia/Shanghai
PORT=8888
HOST_BGMI_PATH=./data/bgmi
"
if [[ $1 == "clean" ]];then
    sudo rm AriaNg* -f
    sudo rm data -rf
    sudo rm ariang -rf
    rm ./.env -f
    exit
fi

bgmi="`which docker-compose` -f `realpath ./docker-compose.yml` run bgmi"

if [[ $1 == "alias" ]];then
    echo "alias bgmi=\"${bgmi}\""
    exit
fi
#exit
if [[ ! -f .env ]] || [[ $1 == "-f" ]];then
    echo "$TEMPLATE"
    echo "$TEMPLATE" > .env
    cat <(crontab -l) <(echo "0 */2 * * * LC_ALL=en_US.UTF-8 ${bgmi} update --download") | crontab -
    cat <(crontab -l) <(echo "0 */10 * * * LC_ALL=en_US.UTF-8 TRAVIS_CI=1 ${bgmi} cal --force-update --download-cover") | crontab -
fi

command -v docker-compose > /dev/null

docker_exists="$?"

if [[ ${docker_exists} -ne 0 ]];then
    echo "you don't have docker-compose, install it first"
    exit ${docker_exists}
fi

ARIA_NG_FILE_NAME="AriaNg-${ARIA_NG_VERSION}.zip"
if [[ ! -f ${ARIA_NG_FILE_NAME} ]];then
    echo "fetching ariang"
    wget -q --show-progress "https://github.com/mayswind/AriaNg/releases/download/${ARIA_NG_VERSION}/${ARIA_NG_FILE_NAME}"
fi

if [[ ! -d ./ariang ]];then
    unzip ${ARIA_NG_FILE_NAME} -d ./ariang
fi

sudo docker-compose build

mkdir ./data/bgmi -p
mkdir ./data/downloads -p

sudo chown -R "`id -u`:`id -g`" data

sudo docker-compose run bgmi install
sudo docker-compose run bgmi config ARIA2_RPC_TOKEN "${ARIA2_TOKEN}"
sudo docker-compose run bgmi config ARIA2_RPC_URL http://aria2:6800/rpc
sudo docker-compose run bgmi config ADMIN_TOKEN "${BGMI_TOKEN}"

sudo docker-compose up -d

