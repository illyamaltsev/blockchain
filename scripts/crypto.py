from web3 import Web3


infura_url = "https://ropsten.infura.io/v3/8ba1cd96047c44ee8b9b89edfb09670d"

web3 = Web3(Web3.HTTPProvider(infura_url))

if web3.isConnected():
    my_wallet = "0x703aaaD2E4697589Dab20203ecB3227591B50605"
    my_private_key = "55E6D7AA677FFE917156A52B3A9A15B0F73176FBBFF7F5276FF66C7CC517916A"
    teacher_wallet = "0xc53D6C0148ddC28Efe623Ab3aD54da5C7779b25C"

    # GET BALANCE
    balance = web3.eth.getBalance(my_wallet)  # not converted
    balance = web3.fromWei(balance, 'ether')  # converted
    print(balance)

    # TRANSACTION
    nonce = web3.eth.getTransactionCount(my_wallet)
    tx = {
        'nonce': nonce,
        'to': teacher_wallet,
        'value': web3.toWei(0.5, 'ether'),
        'gas': 2000000,
        'gasPrice': web3.toWei(50, 'gwei'),
        'data': b'Illya Maltsev'
    }

    singed_tx = web3.eth.account.signTransaction(tx, my_private_key)

    tx_hash = web3.eth.sendRawTransaction(singed_tx.rawTransaction)
    print(tx_hash)



