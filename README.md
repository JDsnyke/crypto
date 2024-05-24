# Docker Bitcoin Stack

![top-language](https://img.shields.io/github/languages/top/JDsnyke/crypto) ![last-commit](https://img.shields.io/github/last-commit/JDsnyke/crypto) ![repo-size](https://img.shields.io/github/repo-size/JDsnyke/crypto) ![tag](https://img.shields.io/github/v/tag/JDsnyke/crypto) ![license](https://img.shields.io/github/license/JDsnyke/crypto)

An all in one Docker stack for installing bitcoin-core, electrs, their relevant web-ui's from Umbrel and a mempool explorer.

## Table of Contents

- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [Lightning Node](#lightning-node)
- [Extra Containers](#extra-containers)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## Getting Started

### Prerequisites

- Ideally a fresh install (not required, but HIGHLY recommended).
- A 64 bit linux based server.
- Access to the server through ssh.
- Git [installed](https://git-scm.com/downloads/).
- Python [installed](https://www.python.org/downloads/).
- Docker [installed](https://docs.docker.com/get-docker/).
- Docker compose [installed](https://docs.docker.com/compose/install/).
- Free storage space of 1.5TB or over.
- A folder for your docker containers.
- Relevant permissions to that folder in order to run bash scripts.

### Installation

This stack works out of the box with no editing. Consider making modifications to make the script more secure.

> [!TIP]
> Refer to the [wiki](https://github.com/JDsnyke/crypto/wiki) for additional configuration options.

1.  SSH into the server using your credentials.

```bash
ssh pi@raspberrypi.local
```

2.  Install the dependencies if you haven't already. An example using the APT package manager is shown below.

```bash
sudo apt install git python3 docker docker-compose --yes
```

3.  Navigate to your docker container folder.

```bash
cd example_docker_folder
```

4.  Clone this repository.

```bash
git clone https://github.com/JDsnyke/crypto.git
```

5.  Double check the permissions for the folder, the parent folder, and its subfolders. An example of setting permissions for your folders is shown below.

> [!IMPORTANT]
> As of version [`v.1.2.0`](https://github.com/JDsnyke/crypto/releases/tag/v.1.2.0), the permissions should be fine by default.

```bash
cd ..
```

```bash
sudo chown -R 1000:1000 example_docker_folder
```

```bash
chmod -R 770 example_docker_folder
```

```bash
ls -l
```

6.  Go into the new `crypto` folder.

```bash
cd example_docker_folder
```

```bash
cd crypto
```

7.  Edit the execution permissions for the `start.sh` script.

```bash
chmod u+x start.sh
```

8.  Run the script.

```bash
./start.sh
```

9.  Visit your active containers!

    [![Bitcoin Node](https://img.shields.io/badge/Bitcoin%20Node-orange.svg)](http://localhost:3005)
    [![Electrum Server](https://img.shields.io/badge/Electrum%20Server-blue.svg)](http://localhost:3006)
    [![Mempool Explorer](https://img.shields.io/badge/Mempool%20Explorer-purple.svg)](http://localhost:3007)

10. Stop the stack.

```bash
./stop.sh
```

## Lightning Node

> [!CAUTION]
> This function does not work at present. Attempt at the cost of your sanity. Report any success.

1. Edit the `start.sh` script file's environment variable or run the file with the the appropriate argument.

```
STACK_RUN_LIGHTNING_SERVER="True" # From False
```

**OR**

```bash
./start.sh --lightning
```

2. Initialize a new wallet using the `lncli` command and follow the provided prompts.

```bash
docker exec -it lnd lncli create
```

3. If things went well, a wallet seed should be created will be shown on the terminal screen.

4. This will in turn allow you to interact with the Umbrel LND container.

   [![Lightning Node](https://img.shields.io/badge/Lightning%20Node-green.svg)](http://localhost:3008)

## Extra Containers

> [!CAUTION]
> This is a WIP feature and will be coming soon (TM).

> [!NOTE]
> I am working on adding additional containers to the script. You will be able to toggle what you want!

> [!TIP]
> Feel free to add requests to the relevant [discussions](https://github.com/JDsnyke/crypto/discussions/6) board.

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/JDsnyke/crypto/blob/main/LICENSE) file for details.

## Acknowledgments

- Files, container images and scripts from the [Umbrel](https://github.com/getumbrel) team.
- Hat tip to anyone else's code that was used.
