FROM melle2/wine-steamcmd-ubuntu:latest

ENV USER_NAME=sunkenland \
    APP_ID=2667530

ENV WORLD_FOLDER="/${USER_NAME}/.wine/drive_c/users/${USER_NAME}/AppData/LocalLow/Vector3 Studio/Sunkenland/"

RUN groupadd -g 7000 ${USER_NAME} && useradd -d /${USER_NAME} -u 7000 -g 7000 -m ${USER_NAME} && \
    mkdir ${USER_NAME}/.steam/ ${USER_NAME}/game && chown 7000:7000 ${USER_NAME}/.steam ${USER_NAME}/game

ADD startSunkenland.sh /${USER_NAME}
RUN chmod 744 /${USER_NAME}/startSunkenland.sh && chown ${USER_NAME}:${USER_NAME} /${USER_NAME}/startSunkenland.sh

USER ${USER_NAME}
WORKDIR /${USER_NAME}
RUN  wine wineboot -i && wineserver -w && mkdir -p "${WORLD_FOLDER}" && ln -s "/${USER_NAME}/Worlds" "${WORLD_FOLDER}"

ENTRYPOINT ["./startSunkenland.sh"]

EXPOSE 27015
