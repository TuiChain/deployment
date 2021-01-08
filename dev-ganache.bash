#!/usr/bin/env bash
# ---------------------------------------------------------------------------- #

set -o errexit -o pipefail -o nounset

# get script directory

script_dir="$( cd "$( dirname "$0" )" && pwd )"

# load utilities

source "${script_dir}/common.bash"

# ---------------------------------------------------------------------------- #

# print help

if (( $# == 0 )); then
    >&2 printf "\
Usage: $0 [options...] <venv_dir>

Runs a development web server locally with a SQLite database, and uses a
local Ganache test network.

This script creates a Python venv at <venv_dir> and installs all
dependencies there. All web server and Ganache network state is also
stored there.

A TuiChain Ethereum master account is generated and used to deploy the
controller contract. Five user accounts are also generated. A mock
ERC-20 contract mimicking the actual Dai contract is deployed in the
test network. All accounts are credited with 100 ether and 100 000 Dai.

This script is idempotent: if any of the steps was already run on the
same <venv_dir>, they are not repeated, and all web server and network
state is maintained between runs.

Pressing Ctrl+D will rebuild the frontend if any changes have been made.
Changes to backend sources are also automatically picked up by the
Django development server without having to rerun this script.

Options:

  --frontend <dir>
    Use the frontend component in the given directory.
    (default is submodule 'frontend' in this script's directory)

  --backend <dir>
    Use the backend component in the given directory.
    (default is submodule 'backend' in this script's directory)

  --blockchain <dir>
    Use the blockchain component in the given directory.
    (default is submodule 'blockchain' in this script's directory)

  --ganache-verbose
    Log requests sent to Ganache.
"
    exit 2
fi

# parse arguments

while (( $# > 0 )); do

    case "$1" in

        --frontend)
            __ensure_option_has_value "$@"
            frontend_dir="$( __resolve "$2" )"
            shift
            shift
            ;;

        --backend)
            __ensure_option_has_value "$@"
            backend_dir="$( __resolve "$2" )"
            shift
            shift
            ;;

        --blockchain)
            __ensure_option_has_value "$@"
            blockchain_dir="$( __resolve "$2" )"
            shift
            shift
            ;;

        --ganache-verbose)
            ganache_verbose=1
            shift
            ;;

        -*)
            __bad_usage "Unknown option $1"
            ;;

        *)
            if [[ -z "${venv_dir+x}" ]]; then
                venv_dir="$1"
                shift
            else
                __bad_usage "Unexpected argument $1"
            fi
            ;;

    esac

done

[[ ! -z "${venv_dir+x}" ]] || __bad_usage "Missing argument <venv_dir>"

[[ ! -z "${frontend_dir+x}" ]] ||
    frontend_dir="$( __resolve "${script_dir}/frontend" )"

[[ ! -z "${backend_dir+x}" ]] ||
    backend_dir="$( __resolve "${script_dir}/backend" )"

[[ ! -z "${blockchain_dir+x}" ]] ||
    blockchain_dir="$( __resolve "${script_dir}/blockchain" )"

num_user_accounts=5

# ---------------------------------------------------------------------------- #

function __set_up_ethereum_network()
{
    # install Ganache

    if ! npx ganache-cli --help > /dev/null 2>&1; then
        __log "Installing Ganache..."
        npm install --silent ganache-cli
    fi

    # start Ganache

    local accounts
    accounts=( ${keys[@]/#/0x} )
    accounts=( ${accounts[@]/%/,100000000000000000000} )

    __log "Starting Ganache test network..."

    [[ -z "${ganache_verbose:-}" ]] &&
        ganache_quiet='/dev/null' ||
        ganache_quiet='/dev/stdout'

    npx ganache-cli \
        --accounts 0 \
        ${accounts[@]/#/--account } \
        --db ganache \
        --port 8545 \
        --keepAliveTimeout 100000000 \
        --secure \
        > "${ganache_quiet}" \
        &

    while ! nc -z localhost 8545 > /dev/null 2>&1; do sleep 1; done

    network_url=http://localhost:8545/
}

__do_things "Local Ganache test network" : __set_up_ethereum_network

# ---------------------------------------------------------------------------- #
