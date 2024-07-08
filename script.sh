#!/bin/bash

WORKDIR=$(pwd)

echo -e "\033[1;34mCreating folder 'zun'...\033[0m"
echo
mkdir -p $WORKDIR/zun && cd $WORKDIR/zun || { echo "Failed to create or navigate to 'zun' folder"; exit 1; }
echo

echo -e "\033[1;34mCreating 'app.html' file...\033[0m"
echo
cat <<EOL > app.html


<!DOCTYPE html>
<html lang="en">
<head>
		<script>
			(function() {
				// Web3:// URL to Gateway URL convertor
				const convertWeb3UrlToGatewayUrl = function(web3Url) {
					// Parse the URL
					let matchResult = web3Url.match(/^(?<protocol>[^:]+):\/\/(?<hostname>[^:/?]+)(:(?<chainId>[1-9][0-9]*))?(?<path>.*)?$/)
					if(matchResult == null) {
						// Invalid web3:// URL
						return null;
					}
					let urlMainParts = matchResult.groups
			
					// Check protocol name
					if(["web3", "w3"].includes(urlMainParts.protocol) == false) {
						// Bad protocol name"
						return null;
					}
			
					// Get subdomain components
					let gateway = window.location.hostname.split('.').slice(-2).join('.') + (window.location.port ? ':' + window.location.port : '');
					let subDomains = []
					// Is the contract an ethereum address?
					if(/^0x[0-9a-fA-F]{40}$/.test(urlMainParts.hostname)) {
						subDomains.push(urlMainParts.hostname)
						if(urlMainParts.chainId !== undefined) {
							subDomains.push(urlMainParts.chainId)
						}
						else {
							// gateway = "w3eth.io"
							subDomains.push(1);
						}
					}
					// It is a domain name
					else {
						// ENS domains on mainnet have a shortcut
						if(urlMainParts.hostname.endsWith('.eth') && urlMainParts.chainId === undefined) {
							// gateway = "w3eth.io"
							// subDomains.push(urlMainParts.hostname.slice(0, -4))
							subDomains.push(urlMainParts.hostname)
							subDomains.push(1)
						}
						else {
							subDomains.push(urlMainParts.hostname)
							if(urlMainParts.chainId !== undefined) {
								subDomains.push(urlMainParts.chainId)
							}
						}
					}
			
					let gatewayUrl = window.location.protocol + "//" + subDomains.join(".") + "." + gateway + (urlMainParts.path ?? "")
					return gatewayUrl;
				}


				const originalFetch = fetch;
				fetch = function(input, init) {
					if (typeof input === 'string' && input.startsWith('web3://')) {
						const convertedUrl = convertWeb3UrlToGatewayUrl(input);
						if(convertedUrl) {
							console.log('Gateway fetch() wrapper: Converted ' + input + ' to ' + convertedUrl);
							input = convertedUrl;
						}
					}

					return originalFetch(input, init);
				};


				document.addEventListener('click', function(event) {
					if(event.target.tagName === 'A' && event.target.href.startsWith('web3://')) {
						event.preventDefault();
						const convertedUrl = convertWeb3UrlToGatewayUrl(event.target.href);
						if(convertedUrl == null) {
							console.log("A tag click wrapper: Unable to convert web3:// URL: " + event.target.href);
							return;
						}
						console.log('A tag click wrapper: Converted ' + event.target.href + ' to ' + convertedUrl);
						window.location.href = convertedUrl;
					}
				});
			})();
		</script>
	
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Head or Tail Prediction Game</title>
    <link href="https://fonts.googleapis.com/css2?family=Lexend:wght@400;700&display=swap" rel="stylesheet">
    <style>
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: linear-gradient(to right, #4280f3, #5ceca4);
            font-family: 'Roboto', sans-serif;
            color: #fff;
            text-align: center;
        }

        .container {
            background: rgba(0, 0, 0, 0.7);
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }

        h1 {
            margin-bottom: 20px;
        }

        button {
            display: block;
            width: 200px;
            padding: 10px;
            margin: 10px auto;
            border: none;
            border-radius: 5px;
            background-color: #b8a70f;
            color: white;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        button:hover {
            background-color: #26c1f0;
        }

        #status {
            margin-top: 20px;
            font-weight: 700;
        }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/web3/dist/web3.min.js"></script>
    <script>
        let contract;
        const contractAddress = '0xC96b2f89863FFCD4Dd9681d7AB096B92b46E4407';
        const abi = [
            {
                "inputs": [],
                "name": "houseBalance",
                "outputs": [
                    {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "uint256",
                        "name": "",
                        "type": "address"
                    }
                ],
                "name": "games",
                "outputs": [
                    {
                        "internalType": "address",
                        "name": "player",
                        "type": "address"
                    },
                    {
                        "internalType": "enum CoinFlip.Bet",
                        "name": "bet",
                        "type": "uint8"
                    },
                    {
                        "internalType": "uint256",
                        "name": "amount",
                        "type": "uint256"
                    },
                    {
                        "internalType": "bool",
                        "name": "isActive",
                        "type": "bool"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [],
                "name": "revealOutcome",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "enum CoinFlip.Bet",
                        "name": "_bet",
                        "type": "uint8"
                    }
                ],
                "name": "placeBet",
                "outputs": [],
                "stateMutability": "payable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "uint256",
                        "name": "_amount",
                        "type": "uint256"
                    }
                ],
                "name": "withdraw",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "anonymous": false,
                "inputs": [
                    {
                        "indexed": true,
                        "internalType": "address",
                        "name": "player",
                        "type": "address"
                    },
                    {
                        "indexed": false,
                        "internalType": "enum CoinFlip.Bet",
                        "name": "bet",
                        "type": "uint8"
                    },
                    {
                        "indexed": false,
                        "internalType": "uint256",
                        "name": "amount",
                        "type": "uint256"
                    }
                ],
                "name": "GameCreated",
                "type": "event"
            },
            {
                "anonymous": false,
                "inputs": [
                    {
                        "indexed": true,
                        "internalType": "address",
                        "name": "player",
                        "type": "address"
                    },
                    {
                        "indexed": false,
                        "internalType": "bool",
                        "name": "won",
                        "type": "bool"
                    },
                    {
                        "indexed": false,
                        "internalType": "enum CoinFlip.Bet",
                        "name": "result",
                        "type": "uint8"
                    },
                    {
                        "indexed": false,
                        "internalType": "uint256",
                        "name": "amount",
                        "type": "uint256"
                    }
                ],
                "name": "GameResult",
                "type": "event"
            }
        ];

        window.onload = async () => {
            if (window.ethereum) {
                window.web3 = new Web3(window.ethereum);
                await window.ethereum.enable();
                contract = new web3.eth.Contract(abi, contractAddress);
            } else {
                alert('Please install MetaMask!');
            }
        };

        async function placeBet(bet) {
            const accounts = await web3.eth.getAccounts();
            const betValue = web3.utils.toWei('0.0001', 'ether');
            contract.methods.placeBet(bet).send({ from: accounts[0], value: betValue })
                .on('receipt', function(receipt) {
                    document.getElementById('status').textContent = 'Bet placed!';
                })
                .on('error', function(error) {
                    console.error(error);
                    document.getElementById('status').textContent = 'Error placing bet.';
                });
        }

        async function revealOutcome() {
            const accounts = await web3.eth.getAccounts();
            contract.methods.revealOutcome().send({ from: accounts[0] })
                .on('receipt', function(receipt) {
                    document.getElementById('status').textContent = 'Check your wallet, you will get 0.0002 ETH if you win';
                })
                .on('error', function(error) {
                    console.error(error);
                    document.getElementById('status').textContent = 'Error revealing outcome.';
                });

            contract.events.GameResult({ fromBlock: 'latest' }, function(error, event) {
                if (error) {
                    console.error(error);
                    return;
                }
                console.log(event);
                const result = event.returnValues;
                const outcome = result.won ? 'You won!' : 'You lost.';
                document.getElementById('status').textContent = `Outcome: ${outcome}`;
            });
        }
    </script>
</head>
<body>
    <div class="container">
        <h1>Head or Tail Prediction Game</h1>
        <button onclick="placeBet(1)">Bet on Heads</button>
        <button onclick="placeBet(2)">Bet on Tails</button>
        <button onclick="revealOutcome()">Reveal Outcome</button>
        <div id="status">Place your bet!</div>
    </div>
</body>
</html>

EOL
echo

echo -e "\033[1;34mFolder 'zun' and file 'app.html' created successfully.\033[0m"
echo

echo -e "\033[1;34mInstalling ethfs-cli globally...\033[0m"
echo
npm i -g ethfs-cli || { echo "Failed to install ethfs-cli"; exit 1; }
echo

read -p 'Enter your private key: ' PRIVATE_KEY
echo

echo -e "\033[1;34mCreating a new filesystem with ethfs-cli...\033[0m"
echo
echo -e "\033[1;35mCOPY THIS DIRECTORY ADDRESS AND SAVE IT SOMEWHERE\033[0m"
echo
ethfs-cli create -p "$PRIVATE_KEY" -c 11155111 || { echo "Failed to create filesystem with ethfs-cli"; exit 1; }
echo

read -p 'Enter the flat directory address: ' FLAT_DIR_ADDRESS
echo

echo -e "\033[1;34mUploading 'zun' folder with ethfs-cli...\033[0m"
echo
ethfs-cli upload -f "$WORKDIR/zun" -a "$FLAT_DIR_ADDRESS" -c 11155111 -p "$PRIVATE_KEY" -t 1 || { echo "Failed to upload folder with ethfs-cli"; exit 1; }
echo

echo -e "\033[1;34mInstalling eth-blob-uploader globally...\033[0m"
echo
npm i -g eth-blob-uploader || { echo "Failed to install eth-blob-uploader"; exit 1; }
echo

read -p 'Enter any EVM wallet address: ' EVM_WALLET_ADDRESS
echo

echo -e "\033[1;34mUploading 'app.html' with eth-blob-uploader...\033[0m"
echo
eth-blob-uploader -r http://88.99.30.186:8545 -p "$PRIVATE_KEY" -f "$WORKDIR/zun/app.html" -t "$EVM_WALLET_ADDRESS" || { echo "Failed to upload app.html with eth-blob-uploader"; exit 1; }
echo

echo -e "\033[1;34mCreating a new filesystem again with ethfs-cli...\033[0m"
echo
echo -e "\033[1;35mCOPY THIS DIRECTORY ADDRESS AND SAVE IT SOMEWHERE\033[0m"
echo
ethfs-cli create -p "$PRIVATE_KEY" -c 11155111 || { echo "Failed to create filesystem with ethfs-cli"; exit 1; }
echo

read -p 'Enter the flat directory address: ' FLAT_DIR_ADDRESS2
echo

echo -e "\033[1;34mUploading 'zun' folder again with ethfs-cli...\033[0m"
echo
echo -e "\033[1;31mThis transaction may get stuck, You should wait 2 mins, If it is still same, start the script from beginning\033[0m"
echo
ethfs-cli upload -f "$WORKDIR/zun" -a "$FLAT_DIR_ADDRESS2" -c 11155111 -p "$PRIVATE_KEY" -t 2 || { echo "Failed to upload folder with ethfs-cli"; exit 1; }
echo

echo -e "\033[1;32mThis is your application’s web3 link:\033[0m https://"$FLAT_DIR_ADDRESS2".3333.w3link.io/app.html"
echo

echo -e "\033[1;32mAll tasks completed successfully.\033[0m"
echo
