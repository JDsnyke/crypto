# Docker Bitcoin Stack

![top-language](https://img.shields.io/github/languages/top/JDsnyke/crypto) ![last-commit](https://img.shields.io/github/last-commit/JDsnyke/crypto) ![repo-size](https://img.shields.io/github/repo-size/JDsnyke/crypto) ![tag](https://img.shields.io/github/v/tag/JDsnyke/crypto) ![license](https://img.shields.io/github/license/JDsnyke/crypto)

An all in one Docker stack for installing bitcoin-core, electrs, their relevant web-ui's from Umbrel and a mempool explorer.

## Table of Contents

- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
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

> Refer to the [wiki](https://github.com/JDsnyke/crypto/wiki) to edit advanced options as needed.

1.  SSH into the server using your credentials.

```bash
ssh pi@raspberrypi.local
```

2.  Install the dependencies if you havn't already.

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

5.  Double check permissions for the folder, the parent folder and it's sub folders. An example of setting permissions for your folders, would be as below.

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

7.  Edit the permissions for the `start.sh` script.

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

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/JDsnyke/crypto/blob/main/LICENSE) file for details.

## Acknowledgments

- Files, container images and scripts from the [Umbrel](https://github.com/getumbrel) team.
- Hat tip to anyone else's code that was used.
