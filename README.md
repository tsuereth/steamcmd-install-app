`steamcmd-install-app` is a containerized tool for installing and/or updating a (publicly-available, Linux-compatible) Steam application to a host-mounted volume.

- It relies on the SteamCMD tool [provided by Valve](https://developer.valvesoftware.com/wiki/SteamCMD). This image uses a _very specific subset_ of SteamCMD functionality to install and update Steam applications. Additional functionality is outside the scope of this repository.

The expected usage of this container image is to initialize application data, like a game's dedicated server executable, for a follow-up runtime environment. In other words:

1. Install or update application data with this container. Mount a volume to this image's `/install-dir-volume` path to save that application data for the next step.

```sh
docker run --rm \
    -v myapp-volume:/install-dir-volume \
    -e CHOWN_UID_GID=1000:1000 \
    steamcmd-install-app MYAPPID
```

_A Steam application's numeric App ID can be found through third-party services such as [SteamDB](https://steamdb.info/apps/)._

For file-permission convenience, the environment variable `CHOWN_UID_GID` can optionally be provided to automatically set the installed files' owning user and group IDs.

2. Then, use that application data on the host - or in another container - to run the application.

```sh
docker run \
    -v myapp-volume:/myapp \
    --user 1000:1000 \
    ubuntu

# The new container can now access application data in /myapp
```

_Why bother containerizing a SteamCMD function separately from the application?_

- Although SteamCMD has a relatively trivial footprint, there's still some hypothetical value in excluding it from a game/application environment, i.e. preventing a dedicated game server from having access to unneeded Steam functionality and metadata.

- By running an application install/update separately from running the application itself, it becomes simple to copy the application data for backup or reuse.

_Got a suggestion or change request?_

This repository is designed for the author's own usage. Contributions are not expected. Feel free to fork this repository and build an image of your own.
