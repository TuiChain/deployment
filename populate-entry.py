# ---------------------------------------------------------------------------- #

from __future__ import annotations

import json
import requests

from dataclasses import dataclass
from pathlib import Path
from sys import argv
from typing import Any, Callable, Optional

from tuichain_ethereum import PrivateKey
from web3 import Account, HTTPProvider, Web3
from web3.contract import fill_transaction_defaults
from web3.types import HexStr, TxParams

# ---------------------------------------------------------------------------- #

base_url = argv[1]
w3 = Web3(provider=HTTPProvider(argv[2]))


@dataclass
class User:

    token: str
    key: Optional[PrivateKey]

    def get(
        self,
        path: str,
        request: Any,
        response_transform: Callable[[Any], Any] = lambda r: r,
    ) -> Any:
        return self._rest(requests.get, path, request, response_transform)

    def post(
        self,
        path: str,
        request: Any,
        response_transform: Callable[[Any], Any] = lambda r: r,
    ) -> Any:
        return self._rest(requests.post, path, request, response_transform)

    def put(
        self,
        path: str,
        request: Any,
        response_transform: Callable[[Any], Any] = lambda r: r,
    ) -> Any:
        return self._rest(requests.put, path, request, response_transform)

    def _rest(
        self,
        method: Any,
        path: str,
        request: Any,
        response_transform: Callable[[Any], Any],
    ) -> Any:

        response = method(
            base_url + path,
            headers={
                "Authorization": f"Token {self.token}",
                "Content-Type": "application/json",
            },
            data=json.dumps(request),
        )

        response.raise_for_status()

        return response_transform(response.json())

    def transact(self, path: str, request: Any) -> None:

        assert self.key is not None

        response = requests.post(
            base_url + path,
            headers={"Content-Type": "application/json"},
            data=json.dumps(request),
        )

        response.raise_for_status()

        for tx in response.json()["transactions"]:

            address = self.key.address._checksummed
            nonce = w3.eth.getTransactionCount(address, "pending")

            params = fill_transaction_defaults(
                w3,
                TxParams(
                    {
                        "data": HexStr(tx["data"]),
                        "from": address,
                        "nonce": nonce,
                        "to": Web3.toChecksumAddress(tx["to"]),
                    }
                ),
            )

            signed = Account.sign_transaction(params, bytes(self.key))

            tx_hash = w3.eth.sendRawTransaction(signed.rawTransaction)
            tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

            assert tx_receipt["status"] == 1


def login_admin() -> User:

    response = requests.post(
        base_url + "/api/auth/login/",
        headers={"Content-Type": "application/json"},
        data=json.dumps({"username": "admin", "password": "admin"}),
    )

    response.raise_for_status()

    return User(token=response.json()["token"], key=None)


def signup_user(
    username: str,
    password: str,
    email: str,
    first_name: str,
    last_name: str,
    ethereum_key: str,
) -> User:

    response = requests.post(
        base_url + "/api/auth/login/",
        headers={"Content-Type": "application/json"},
        data=json.dumps({"username": username, "password": password}),
    )

    if response.status_code == 404:

        response = requests.post(
            base_url + "/api/auth/signup/",
            headers={"Content-Type": "application/json"},
            data=json.dumps(
                {
                    "username": username,
                    "password": password,
                    "email": email,
                    "first_name": first_name,
                    "last_name": last_name,
                }
            ),
        )

    response.raise_for_status()

    return User(
        token=response.json()["token"],
        key=PrivateKey(bytes.fromhex(ethereum_key)),
    )

oneDai = 10 ** 18

# ---------------------------------------------------------------------------- #

exec(compile(Path("../populate.py").read_text(), "populate.py", "exec"))

# ---------------------------------------------------------------------------- #
