## Sunkenland Dedicated Server
This image is based on wine, Xvfb and SteamCMD. It does already have an installed version of Sunkenland, but it is also able to update the version at any time.

## What you should know
1. This image is based on another "basic image" (wine-steamcmd-ubuntu), which I've created to not only use it for Sunkenland, but also for all other kind of Windows based dedicated game servers. 
2. You should have a basic understanding how to deal with Docker and Linux. All documentation is based on a Linux environment. However, it is possible to run this also in a Windows environment which has an installation of Docker/K8s. 
3. Internally the dedicated server is executed as user/group "sunkenland" - UserID 7000, GroupId 7000.

## How to start
1. Create your own World in Sunkenland game - or re-use an already existing world.
2. Copy the World folder to a target destination on your host (i.e. /opt/sunkenland).
3. You must change the owner:group of your target folder to 7000:7000.
4. Run your container with docker or docker-compose.

### Volume
Within the image, Sunkenland Dedicated Server is installed to folder `/sunkenland` which also is the home directory for `sunkenland` user. The implementation expects the world files mounted to `/sunkenland/Worlds`.
If the Sunkenland Dedicated Server cannot find the world files, it will post the respective message to the console.

However, you can even mount the complete folder `/sunkenland`, but bear in mind that internally a soft-link is used to link the world folder from `/sunkenland/Worlds` to the respective "Windows" target location. If you want to do this, you have to add a mount for the target location, too. The target location is defined in `Dockerfile` environment variable `WORLD_FOLDER`. What you have to do in any case is to change the owner:group of the mounted folder.  

### Ports
If your port is already blocked by another game, you can change the port mapping to something different, i.e. `-p 29015:27015`

### Game updates
With this image it is possible to update the game to the latest version - see `GAME_UPDATE` parameter. It is also possible to get a beta version - see `GAME_BETA_VERSION`. Keep in mind, a beta server might not be available for a specific beta client version.

### Environment variables
The only mandatory requirement for Sunkeland to be able to run is to pass the WorlGUID as a start parameter. Additionally, to gain more control about some of the Sunkenland Dedicated Server configuration parameter, you can set some more specific environment variables.
You can find the full documentation of all parameters [here](https://www.sunkenlandgame.com/post/dedicated-server-user-manual).

| Parameter name         |                                                                                                                              Description                                                                                                                              | Default value | Mandatory |
|:-----------------------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|--------------:|----------:|
| GAME_WORLD_GUID        |                                                 Set the WorldGUID for Sunkenland. Without this parameter Sunkenland is not able to start. Will be checked if set during startup and logs an error message if not set                                                  |             - |       yes |
| GAME_PASSWORD          |                                                                                                      Set the game password. Maximum allowed password length is 8                                                                                                      |             - |        no |
| GAME_REGION            |                                                  Set the region for Sunkenland Dedicated Server.see [official documentation](https://www.sunkenlandgame.com/post/dedicated-server-user-manual) for more information                                                   |            eu |        no |
| GAME_MAX_PLAYER        |                                                                                                    Set the maximum of allowed player for your instance. Max is 15.                                                                                                    |             3 |        no |
| GAME_SESSION_INVISIBLE |                 Set the game session to invisible. If set to "true", game will not be visible in the dedicated server overview within the game. You must either invite your friends or join by ServerID which is posted to the console after startup                  |         false |        no |
| GAME_UPDATE            |                                                           As this image already contains a pre-installed version of Sunkenland, with this parameter you are able to update to the latest available version                                                            |         false |        no |
| GAME_BETA_VERSION      | With this parameter you're able to pass a beta version (if it is available). This only is considered in combination with parameter `GAME_UPDATE: true`. Example: `GAME_BETA_VERSION: publictest`. Do not set this value if you want to run the latest public release. |         false |        no |

### Docker
Example (minimal) docker exec command:
```
docker run -d \
	--name sunkenland-dedicated-server \
	-p 27015:27015 \
	-e GAME_WORLD_GUID=<world_guid> \
	-v /opt/sunkenland/:/sunkenland/Worlds \
	melle2/sunkenland-ds:latest
```

### Docker Compose
Example docker-compose yaml configuration
```
services:
  sunkenland:
    container_name: sunkenland-dedicated-server
    image: melle2/sunkenland-ds:latest
    restart: always
    environment:
      GAME_WORLD_GUID: <world_guid>
      GAME_PASSWORD: <password>
      GAME_REGION: <your_region>
      GAME_MAX_PLAYER: <number_max_players>
      GAME_SESSION_INVISIBLE: <true/false>
      GAME_UPDATE: <true/false>
      GAME_BETA_VERSION: <branch_name>
    ports:
      - 27015:27015
    volumes:
      - /opt/sunkenland/:/sunkenland/Worlds
```

### DockerHub
Docker Image is available at https://hub.docker.com/repository/docker/melle2/sunkenland-ds.
`docker pull melle2/sunkenland-ds`

### Improvements
If you see improvements, feel free to contribute and create a PR.