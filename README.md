<!-- ----------------------------------------------------------------------- -->

# TuiChain: Deployment

This repository contains scripts to deploy the TuiChain application:

- `dev-ganache.bash` - Runs a development web server locally with a SQLite database, and uses a local Ganache Ethereum test network. (You probably want to use this one.)
- `dev-testnet.bash` - Runs a development web server locally with a SQLite database, and uses a public Ethereum test network through Infura.

Run a script without any arguments for more information.

The other three repositories are included here as submodules, the idea being to store in this repo a working combination of specific versions of those repos. The scripts automatically initialize and update them.

## Dependencies

- You must have Python 3.8 (or higher) and `npm` installed.
- On Debian/Ubuntu you probably also need: `sudo apt-get install python3-dev`

<!-- ----------------------------------------------------------------------- -->
