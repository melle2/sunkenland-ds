#!/usr/bin/env bash
set -e

  # Check if .X1-lock file exists and remove. Otherwise Xvfb cannot start.
  if  test -f /tmp/.X1-lock; then
    rm /tmp/.X1-lock
  fi

_terminate() {
  echo "Caught signal!"
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
  MAX_PLAYER_PARAM="-maxPlayerCapacity ${GAME_MAX_PLAYER}"
fi

if ${GAME_SESSION_INVISIBLE} = true; then
  SESSION_INVISIBLE="-makeSessionInvisible true"
fi

if ${GAME_UPDATE} = true; then
  echo "Start game update..."
  steamcmd +force_install_dir /${USER_NAME} +login anonymous +@sSteamCmdForcePlatformType windows +app_update ${APP_ID} validate +quit
  echo "Game update done"
fi

/etc/init.d/xvfb start
exec wine Sunkenland-DedicatedServer.exe -nographics -batchmode -worldGuid "${GAME_WORLD_GUID}" ${SESSION_INVISIBLE} \
        -password "${GAME_PASSWORD}" ${MAX_PLAYER_PARAM} -region "${GAME_REGION}" &

wait
