FROM melle2/wine-steamcmd-ubuntu:24.04-3

ENV USER_NAME=sunkenland \
    APP_ID=2667530
ENV WORLD_FOLDER="/${USER_NAME}/.wine/drive_c/users/${USER_NAME}/AppData/LocalLow/Vector3 Studio/Sunkenland/"

ARG USER_ID=7000
ARG GROUP_ID=7000


RUN groupadd -g ${USER_ID} ${USER_NAME} && useradd -d /${USER_NAME} -u ${USER_ID} -g ${GROUP_ID} -m ${USER_NAME} && \
    mkdir ${USER_NAME}/.steam/ ${USER_NAME}/game && chown ${USER_ID}:${GROUP_ID} ${USER_NAME}/.steam ${USER_NAME}/game

ADD startSunkenland.sh /${USER_NAME}
RUN chmod 744 /${USER_NAME}/startSunkenland.sh && chown ${USER_ID}:${GROUP_ID} /${USER_NAME}/startSunkenland.sh

USER ${USER_NAME}
WORKDIR /${USER_NAME}
ENV WINEDEBUG=fixme-all,err+all
ENV XDG_RUNTIME_DIR="/tmp/runtime-sunnkenland"

RUN mkdir -p ${XDG_RUNTIME_DIR} && chmod 700 ${XDG_RUNTIME_DIR} && chown ${USER_ID}:${GROUP_ID} ${XDG_RUNTIME_DIR} && \
    wine wineboot -i && wineserver -w && \
    wine reg delete "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Services\winebth" /f && wineserver -k && \
    mkdir -p "${WORLD_FOLDER}" && ln -s "/${USER_NAME}/Worlds" "${WORLD_FOLDER}"

ENTRYPOINT ["./startSunkenland.sh"]

EXPOSE 27015
