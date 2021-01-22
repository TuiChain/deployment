# ---------------------------------------------------------------------------- #

# signup and login

admin = login_admin()

alice = signup_user(
    username="alice",
    password="alice",
    email="alice@example.com",
    first_name="Alice",
    last_name="Smith",
    ethereum_key=argv[3],
)

bob = signup_user(
    username="bob",
    password="bob",
    email="bob@example.com",
    first_name="Bob",
    last_name="Smith",
    ethereum_key=argv[4],
)

charlie = signup_user(
    username="charlie",
    password="charlie",
    email="charlie@example.com",
    first_name="Charlie",
    last_name="Smith",
    ethereum_key=argv[5],
)

dough = signup_user(
    username="dough",
    password="dough",
    email="dough@example.com",
    first_name="Dough",
    last_name="Smith",
    ethereum_key=argv[6],
)

eve = signup_user(
    username="eve",
    password="eve",
    email="eve@example.com",
    first_name="Eve",
    last_name="Smith",
    ethereum_key=argv[7],
)

# set up Alice's loan

alice_loan_id = alice.post(
    path="/api/loans/new/",
    request={
        "school": "University of Alice",
        "course": "Alice Engineering",
        "requested_value_atto_dai": str(10000 * oneDai),
        "destination": "Portugal",
        "description": "Hi, I am Alice.",
        "recipient_address": str(alice.key.address),
    },
    response_transform=lambda r: r["loan"],
)

admin.put(
    path=f"/api/loans/validate/{alice_loan_id}/",
    request={
        "days_to_expiration": "30",
        "funding_fee_atto_dai_per_dai": str(3 * oneDai // 100),
        "payment_fee_atto_dai_per_dai": str(5 * oneDai // 100),
    },
)

dough.transact(
    path="/api/loans/transactions/provide_funds/",
    request={
        "loan_id": alice_loan_id,
        "value_atto_dai": str(5000 * oneDai),
    },
)

# set up Bob's loan

bob_loan_id = bob.post(
    path="/api/loans/new/",
    request={
        "school": "University of Bob",
        "course": "Bob Engineering",
        "requested_value_atto_dai": str(10000 * oneDai),
        "destination": "Portugal",
        "description": "Hi, I am Bob.",
        "recipient_address": str(bob.key.address),
    },
    response_transform=lambda r: r["loan"],
)

admin.put(
    path=f"/api/loans/validate/{bob_loan_id}/",
    request={
        "days_to_expiration": "30",
        "funding_fee_atto_dai_per_dai": str(3 * oneDai // 100),
        "payment_fee_atto_dai_per_dai": str(5 * oneDai // 100),
    },
)

dough.transact(
    path="/api/loans/transactions/provide_funds/",
    request={
        "loan_id": bob_loan_id,
        "value_atto_dai": str(5000 * oneDai),
    },
)

eve.transact(
    path="/api/loans/transactions/provide_funds/",
    request={
        "loan_id": bob_loan_id,
        "value_atto_dai": str(5000 * oneDai),
    },
)

# set up Charlie's loan

charlie_loan_id = charlie.post(
    path="/api/loans/new/",
    request={
        "school": "University of Charlie",
        "course": "Charlie Engineering",
        "requested_value_atto_dai": str(10000 * oneDai),
        "destination": "Portugal",
        "description": "Hi, I am Charlie.",
        "recipient_address": str(charlie.key.address),
    },
    response_transform=lambda r: r["loan"],
)

admin.put(
    path=f"/api/loans/validate/{charlie_loan_id}/",
    request={
        "days_to_expiration": "30",
        "funding_fee_atto_dai_per_dai": str(3 * oneDai // 100),
        "payment_fee_atto_dai_per_dai": str(5 * oneDai // 100),
    },
)

dough.transact(
    path="/api/loans/transactions/provide_funds/",
    request={
        "loan_id": charlie_loan_id,
        "value_atto_dai": str(5000 * oneDai),
    },
)

eve.transact(
    path="/api/loans/transactions/provide_funds/",
    request={
        "loan_id": charlie_loan_id,
        "value_atto_dai": str(5000 * oneDai),
    },
)

charlie.transact(
    path="/api/loans/transactions/make_payment/",
    request={"loan_id": charlie_loan_id, "value_atto_dai": str(12000 * oneDai)},
)

admin.put(path=f"/api/loans/finalize/{charlie_loan_id}/", request={})

# create sell position by Dough of tokens of Alice's loan

eve.transact(
    path="/api/market/transactions/create_sell_position/",
    request={
        "loan_id": bob_loan_id,
        "amount_tokens": 2500,
        "price_atto_dai_per_token": str(15 * oneDai // 10),
    },
)

# ---------------------------------------------------------------------------- #
