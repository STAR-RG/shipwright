# Shipwright: A Human-in-the-Loop System for Dockerfile Repair

ICSE 2021 Artifact for: _Shipwright: A Human-in-the-Loop System for Dockerfile Repair._ This artifact and paper build off of data and tools from [binnacle (ICSE'20)](https://github.com/jjhenkel/binnacle-icse2020).

## Required files

In the root directory of this repository you can find:

1. [`STATUS.md` -- containing the badges we request.](./STATUS.md)
2. [`INSTALL.md` -- containing install directions.](./INSTALL.md)
3. [`REQUIREMENTS.md` -- containing prerequisites for running this artifact.](./REQUIREMENTS.md)
4. [`LICENSE.md` -- containing an open source (MIT) license.](./LICENSE.md)
5. [And a PDF of our submitted paper.](./paper)

## Running this artifact

To run and evaluate this artifact, you can use on or more of the following commands:

```bash
# To run things related to our paper's rq1
./shipwright.sh run-rq1

# To run things related to our paper's rq2
./shipwright.sh run-rq2

# To run things related to our paper's rq3
./shipwright.sh run-rq3

# To extract raw build results 
# NOTE: this uses many CPU cores during decompression
# and may take a few minutes to complete
./shipwright.sh extract
```

Just running `./shipwright.sh` will show all available commands. To see data related to our `rq4`, you can reference the [`./rq4/README.md` (link)](./rq4) file which includes a breakdown of the pull requests we sent and their statuses.

Additionally, many of the folders in this repository include additional details on the options for various commands and the data we've included with this artifact. (See, for example, `./data/README.md`.)

## Troubleshooting docker 'permission denied' errors

If you have just set up a fresh Docker installation and are attempting to run the `./shipwright.sh` script, you may encounter `permission denied` errors. Many docker installations are configured so that the user who runs docker is in the `docker` group. To fix this, you can follow these steps ([or reference this link](https://www.digitalocean.com/community/questions/how-to-fix-docker-got-permission-denied-while-trying-to-connect-to-the-docker-daemon-socket)):

1. Run `sudo usermod -aG docker ${USER}`
2. Close all terminals / logout 
3. Log back in 

The above instructions assume you're on linux. Alternatively, you should be able to run `sudo ./shipwright.sh` if you don't want to add yourself to the `docker` group.

