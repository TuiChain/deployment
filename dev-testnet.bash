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
Usage: $0 [options...] <venv_dir> <network>

Runs a development Create-React-App server and a development Django
server locally with a SQLite database, and uses a public Ethereum test
network through Infura.

This script creates a Python venv at <venv_dir> and installs all
dependencies there. All database state is also stored there. The
<network> must be 'ropsten', 'kovan', 'rinkeby', or 'goerli'.

This script will not generate a TuiChain Ethereum master account since
it can't automatically provide it with ether. You must instead specify
an existing account with --master when first creating the venv.

A mock ERC-20 contract mimicking the actual Dai contract is deployed
using the master account and the latter is credited with 100 000 Dai,
unless an existing contract is given with --dai. A controller contract
is deployed using the master account, unless an existing controller is
given with --controller.

This script is idempotent: if any of the steps was already run on the
same <venv_dir>, they are not repeated, and all database state is
maintained between runs.

Options:

  --frontend @<hash_or_branch>
  --frontend <local_dir>
    If the argument starts with @, use the frontend component at the
    commit with the given (full) hash or at the given branch of its
    repo. Otherwise use the component in the given local directory.
    (default is branch main)

  --backend @<hash_or_branch>
  --backend <local_dir>
    If the argument starts with @, use the backend component at the
    commit with the given (full) hash or at the given branch of its
    repo. Otherwise use the component in the given local directory.
    (default is branch main)

  --blockchain @<hash_or_branch>
  --blockchain <local_dir>
    If the argument starts with @, use the blockchain component at the
    commit with the given (full) hash or at the given branch of its
    repo. Otherwise use the component in the given local directory.
    (default is branch main)

  --master <private_key>
    Use the given master account and set it as the default.

  --dai <address>
    Use the given ERC-20 contract as Dai and set it as the default.
    (if this option is not given and no Dai contract is set as the
    default, a new one is deployed and set as the default)

  --controller <address>
    Use the given controller contract and set it as the default.
    (if this option is not given and no controller is set as the
    default, a new one is deployed and set as the default)
"
    exit 2
fi

# parse arguments

while (( $# > 0 )); do

    case "$1" in

        --frontend)
            __ensure_option_has_value "$@"
            frontend_dir="$2"
            shift
            shift
            ;;

        --backend)
            __ensure_option_has_value "$@"
            backend_dir="$2"
            shift
            shift
            ;;

        --blockchain)
            __ensure_option_has_value "$@"
            blockchain_dir="$2"
            shift
            shift
            ;;

        --master)
            __ensure_option_has_value "$@"
            master_account_private_key="$2"
            shift
            shift
            ;;

        --dai)
            __ensure_option_has_value "$@"
            dai_contract_address="$2"
            shift
            shift
            ;;

        --controller)
            __ensure_option_has_value "$@"
            controller_contract_address="$2"
            shift
            shift
            ;;

        -*)
            __bad_usage "Unknown option $1"
            ;;

        *)
            if [[ -z "${venv_dir+x}" ]]; then
                venv_dir="$1"
                shift
            elif [[ -z "${network+x}" ]]; then
                case "$1" in
                    ropsten) ;;
                    kovan) ;;
                    rinkeby) ;;
                    goerli) ;;
                    *) __bad_usage "Unknown network $1" ;;
                esac
                network="$1"
                shift
            else
                __bad_usage "Unexpected argument $1"
            fi
            ;;

    esac

done

[[ ! -z "${venv_dir+x}" ]] || __bad_usage "Missing argument <venv_dir>"
[[ ! -z "${network+x}" ]] || __bad_usage "Missing argument <network>"

# ---------------------------------------------------------------------------- #

function __after_creating_venv()
{
    [[ -z "${master_account_private_key+x}" ]] ||
        echo "${master_account_private_key}" > ethereum-accounts.txt

    [[ -e ethereum-accounts.txt || ! -z "${master_account_private_key+x}" ]] ||
        __fail "Must set a master account with --master when first creating the venv."

    [[ -z "${dai_contract_address+x}" ]] ||
        echo "${dai_contract_address}" > ethereum-dai-contract.txt

    [[ -z "${controller_contract_address+x}" ]] ||
        echo "${controller_contract_address}" > ethereum-controller-contract.txt
}

function __set_up_ethereum_network()
{
    network_url="https://${network}.infura.io/v3/72e8c88a9b3145fe9612b13b848cf5cb"
}

network_pretty_name="$( echo "${network:0:1}" | tr a-z A-Z )${network:1}"

__do_things "Public ${network_pretty_name} test network" \
    __after_creating_venv __set_up_ethereum_network

# ---------------------------------------------------------------------------- #
