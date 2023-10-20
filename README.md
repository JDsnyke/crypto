# Docker Bitcoin Stack

![last-commit](https://img.shields.io/github/last-commit/JDsnyke/crypto.svg) ![license](https://img.shields.io/github/license/JDsnyke/crypto.svg)

An all in one Docker stack for installing bitcoin-core, electrs, their relevant web-ui's from Umbrel and a mempool explorer.

Additional extra container options available for setting up a complete server environment.

## Getting Started

### Prerequisites

- Ideally a fresh install (not required, but HIGHLY recommended).
- A linux based server.
- Access to the server through ssh.
- Docker compose [installed](https://docs.docker.com/compose/install/).
- A folder for your docker containers.
- Relevant permissions to that folder in order to run bash scripts.

### Installation

This stack works out of the box with no editing.

> Refer to the [wiki](https://github.com/JDsnyke/crypto/wiki) to edit advanced options as needed.

1.  ssh into the server using your credentials.

        ssh pi@raspberrypi.local

2.  Navigate to your docker container folder.

        cd /your/docker/container/folder

3.  Clone this repository.

        git clone https://github.com/JDsnyke/crypto.git

4.  Go into the new `crypto` folder.

        cd crypto

5.  Edit the permissions for the `start.sh` script.

        chmod u+x start.sh

6.  Run the script.

        ./start.sh

7.  Visit your active containers!

    [![Bitcoin Node](https://img.shields.io/badge/Bitcoin%20Node-orange.svg)](http://localhost:3005)
    [![Electrum Server](https://img.shields.io/badge/Electrum%20Server-blue.svg)](http://localhost:3006)
    [![Mempool Explorer](https://img.shields.io/badge/Mempool%20Explorer-purple.svg)](http://localhost:3002)

8.  Stop the stack.

        ./stop.sh

## License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/JDsnyke/crypto/blob/main/LICENSE) file for details.

## Acknowledgments

- Files, container images and scripts from the [Umbrel](https://github.com/getumbrel) team.
- Hat tip to anyone else's code that was used.
