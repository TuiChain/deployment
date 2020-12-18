<!-- ----------------------------------------------------------------------- -->

# TuiChain: Deployment

This repository contains scripts to deploy the TuiChain application:

- `dev-ganache.bash` - Runs a development web server locally with a SQLite database, and uses a local Ganache Ethereum test network. (You probably want to use this one.)
- `dev-testnet.bash` - Runs a development web server locally with a SQLite database, and uses a public Ethereum test network through Infura.

Run a script without any arguments for more information.

The other three repositories are included here as submodules, the idea being to store in this repo a working combination of specific versions of those repos.
To use these submodules, do the usual `git submodule init && git submodule update` dance.

<!-- ----------------------------------------------------------------------- -->
