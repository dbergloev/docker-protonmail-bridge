# ProtonMail Bridge

This docker image contains a setup of [ProtonMail Bidge](https://proton.me/mail/bridge) that can be shared by multiple clients _(applications)_. It allows you to have a central SMTP/IMAP server that can connect to your Proton account and be used by an email client, selfhosted websites etc. without having to setup and run a bridge instance for each purposes. 

It is well known that ProtonMail Bridge can be dificult in this regard due to the fact that it only listens on `localhost/127.0.0.1`. However this image deals with this fact while also exposing the standard ports for SMTP and IMAP.

> This image is configured to run ProtonMail Bridge as an isolated user rather than the container root.

## Usage

### docker

```
docker create \
  --name=protonmail-bridge \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=America/New_York \
  -v ./config:/config \
  -p 25:25/tcp \
  -p 143:143/tcp \
  --restart unless-stopped \
  <repo>/<image>:latest
```


### docker-compose

```
---
services:
  protonmail-bridge:
    image: <repo>/<image>:latest
    container_name: protonmail-bridge
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=America/New_York
    volumes:
      - ./config:/config
    ports:
      - 25:25/tcp
      - 143:143/tcp
    restart: unless-stopped
```

## Configure

Before the container can actually be used, you will have to manually login to your Proton account. This cannot be set using variables due to the 2FA that Proton requires. Follow these steps in the terminal, after you have created the container.

```sh
docker exec -it <container> bash
su docker_user
screen -r
```

You should now be inside the ProtonMail Bridge CLI terminal. Now login.

```
>>> login
```

Follow the steps and enter your account name, password and the required 2FA code. Then wait for it to sync your account. When it is done get the auth information that must be used when accessing the SMTP and IMAP services from a client. Your normal Proton account password will not work. 

```
>>> info
```

Write it down and now you can press `Ctrl+A -> D` to get out of the screen instance while keeping it running. Your container is now ready and you should be able to access SMTP and IMAP on your host ip using port 25 and 143.

## Parameters

Container images are configured using parameters passed at runtime (such as those above).

| Parameter | Examples/Options | Function |
| :----: | --- | --- |
| PUID | 1000 | The nummeric user ID to run the application as, and assign to the user docker_user |
| PGID | 1000 | The numeric group ID to run the application as, and assign to the group docker_group |
| TZ=Europe/London | The timezone to run the container in |

> Note that the PUID and PGID are used to run ProtonMail Bridge. As such these ids must have read and write access to the /config directory. If these variables are not set, then default values are used and may give read/write issues. 

## Volumes

| Volume | Function |
| :----: | --- |
| /config | The home directory of docker_user `PUID` |

## Building locally

```
git clone https://github.com/dbergloev/docker-protonmail-bridge.git
cd docker-protonmail-bridge
docker build \
  --no-cache \
  -t <repo>/<image>:latest .
```
