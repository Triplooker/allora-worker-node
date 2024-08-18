#!/bin/bash

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

install_prerequisites() {
    echo "Installing prerequisites..."
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y ca-certificates zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev curl git wget make jq build-essential pkg-config lsb-release libssl-dev libreadline-dev libffi-dev gcc screen unzip lz4 python3 python3-pip

    if ! command_exists docker; then
        echo "Installing Docker..."
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
        sudo groupadd docker
        sudo usermod -aG docker $USER
    fi

    if ! command_exists docker-compose; then
        echo "Installing Docker Compose..."
        VER=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
        curl -L "https://github.com/docker/compose/releases/download/${VER}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
    fi

    if ! command_exists go; then
        echo "Installing Golang..."
        sudo rm -rf /usr/local/go
        curl -L https://go.dev/dl/go1.22.4.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
        echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
        source $HOME/.bash_profile
    fi
}

install_allora_cli() {
    echo "Installing Allora CLI..."
    git clone https://github.com/allora-network/allora-chain.git
    cd allora-chain && make all
    allorad version || { echo "Allora CLI not found"; exit 1; }
    cd ..
}

create_config() {
    echo "Creating config.json..."
    read -p "Enter your wallet seed phrase: " addressRestoreMnemonic
    read -p "Enter your CoinGecko API key: " coingeckoApiKey
    cat <<EOF > config.json
{
    "wallet": {
        "addressKeyName": "testkey",
        "addressRestoreMnemonic": "$addressRestoreMnemonic",
        "alloraHomeDir": "",
        "gas": "1000000",
        "gasAdjustment": 1.0,
        "nodeRpc": "https://beta.multi-rpc.com/allora_testnet/",
        "maxRetries": 1,
        "delay": 1,
        "submitTx": false
    },
    "api": {
        "coingeckoApiKey": "$coingeckoApiKey"
    },
    "worker": [
        {
            "topicId": 1,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 1,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "ETH"
            }
        },
        {
            "topicId": 2,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 3,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "ETH"
            }
        },
        {
            "topicId": 3,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 5,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "BTC"
            }
        },
        {
            "topicId": 4,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 2,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "BTC"
            }
        },
        {
            "topicId": 5,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 4,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "SOL"
            }
        },
        {
            "topicId": 6,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 5,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "SOL"
            }
        },
        {
            "topicId": 7,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 2,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "ETH"
            }
        },
        {
            "topicId": 8,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 3,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "BNB"
            }
        },
        {
            "topicId": 9,
            "inferenceEntrypointName": "api-worker-reputer",
            "loopSeconds": 5,
            "parameters": {
                "InferenceEndpoint": "http://inference:8000/inference/{Token}",
                "Token": "ARB"
            }
        }
    ]
}
EOF
}

create_requirements() {
    echo "Creating requirements.txt..."
    cat <<EOF > requirements.txt
# Укажите ваши зависимости Python здесь
flask
requests
numpy
pandas
# Добавьте другие зависимости по мере необходимости
EOF
}

create_dockerfiles() {
    echo "Creating Dockerfiles..."
    
    # Dockerfile для Ethereum
    cat <<EOF > Dockerfile.eth
FROM python:3.9-slim
WORKDIR /app
COPY . /app
RUN pip install -r requirements.txt
CMD ["python3", "your_eth_script.py"]  # Замените на ваш скрипт
EOF

    # Dockerfile для Bitcoin
    cat <<EOF > Dockerfile.btc
FROM python:3.9-slim
WORKDIR /app
COPY . /app
RUN pip install -r requirements.txt
CMD ["python3", "your_btc_script.py"]  # Замените на ваш скрипт
EOF

    # Dockerfile для Cardano
    cat <<EOF > Dockerfile.ada
FROM python:3.9-slim
WORKDIR /app
COPY . /app
RUN pip install -r requirements.txt
CMD ["python3", "your_ada_script.py"]  # Замените на ваш скрипт
EOF

    # Dockerfile для Solana
    cat <<EOF > Dockerfile.sol
FROM python:3.9-slim
WORKDIR /app
COPY . /app
RUN pip install -r requirements.txt
CMD ["python3", "your_sol_script.py"]  # Замените на ваш скрипт
EOF

    # Dockerfile для Ripple
    cat <<EOF > Dockerfile.xrp
FROM python:3.9-slim
WORKDIR /app
COPY . /app
RUN pip install -r requirements.txt
CMD ["python3", "your_xrp_script.py"]  # Замените на ваш скрипт
EOF

    # Dockerfile для Litecoin
    cat <<EOF > Dockerfile.ltc
FROM python:3.9-slim
WORKDIR /app
COPY . /app
RUN pip install -r requirements.txt
CMD ["python3", "your_ltc_script.py"]  # Замените на ваш скрипт
EOF
}

create_docker_compose() {
    echo "Creating docker-compose.yml..."
    cat <<EOF > docker-compose.yml
version: '3.8'
services:
  inference-basic-eth-pred:
    build:
      context: .
      dockerfile: Dockerfile.eth
    container_name: inference-basic-eth-pred
    ports:
      - "8001:8000"
    volumes:
      - ./data:/app/data

  inference-basic-btc-pred:
    build:
      context: .
      dockerfile: Dockerfile.btc
    container_name: inference-basic-btc-pred
    ports:
      - "8002:8000"
    volumes:
      - ./data:/app/data

  inference-basic-ada-pred:
    build:
      context: .
      dockerfile: Dockerfile.ada
    container_name: inference-basic-ada-pred
    ports:
      - "8003:8000"
    volumes:
      - ./data:/app/data

  inference-basic-sol-pred:
    build:
      context: .
      dockerfile: Dockerfile.sol
    container_name: inference-basic-sol-pred
    ports:
      - "8004:8000"
    volumes:
      - ./data:/app/data

  inference-basic-xrp-pred:
    build:
      context: .
      dockerfile: Dockerfile.xrp
    container_name: inference-basic-xrp-pred
    ports:
      - "8005:8000"
    volumes:
      - ./data:/app/data

  inference-basic-ltc-pred:
    build:
      context: .
      dockerfile: Dockerfile.ltc
    container_name: inference-basic-ltc-pred
    ports:
      - "8006:8000"
    volumes:
      - ./data:/app/data
EOF
}

# Основной процесс
install_prerequisites
install_allora_cli
create_config
create_requirements
create_dockerfiles
create_docker_compose

echo "Running the worker..."
docker-compose up -d --build

echo "Setup complete. You can check your Allora point for 24 hours after finishing."
echo "Subscribe: https://t.me/HappyCuanAirdrop"