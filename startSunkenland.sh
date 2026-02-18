#!/usr/bin/env bash
set -e

# Check if .X1-lock file exists and remove. Otherwise Xvfb cannot start.
[ -f /tmp/.X1-lock ] && rm -f /tmp/.X1-lock

_terminate() {
  echo "Caught TERM signal!"
  echo "Stopping Sunkenland"
  wineserver -k -w
  /etc/init.d/xvfb stop
}

trap _terminate HUP INT QUIT TERM

if [ -z "${GAME_WORLD_GUID}" ]; then
  echo "Please set environment variable 'GAME_WORLD_GUID', game cannot start otherwise."
  exit 1
fi

if [ -z "${GAME_REGION}" ]; then
  GAME_REGION=eu
fi

if [[ ${GAME_MAX_PLAYER} =~ ^[0-9]+$ ]]; then
  MAX_PLAYER_PARAM=" -maxPlayerCapacity ${GAME_MAX_PLAYER}"
fi

if [ "${GAME_SESSION_INVISIBLE}" = true ]; then
  SESSION_INVISIBLE=" -makeSessionInvisible true"
fi

if [ "$GAME_UPDATE" = true ] || [ -z "$(ls -A /sunkenland/game)" ]; then
  if [ -n "${GAME_BETA_VERSION}" ]; then
    BETA_VERSION=" -beta ${GAME_BETA_VERSION}"
    echo "Updating to beta version ${GAME_BETA_VERSION}"
  fi
  echo "Start game update..."
  steamcmd +force_install_dir /${USER_NAME}/game +@sSteamCmdForcePlatformType windows +login anonymous +app_update \
           "${APP_ID}" ${BETA_VERSION} validate +quit
  echo "Game update done"
fi

/etc/init.d/xvfb start
wine /${USER_NAME}/game/Sunkenland-DedicatedServer.exe -nographics -batchmode -worldGuid ${GAME_WORLD_GUID}${MAX_PLAYER_PARAM}${SESSION_INVISIBLE} -password "${GAME_PASSWORD}" -region "${GAME_REGION}" &

wait
