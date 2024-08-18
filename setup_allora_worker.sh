#!/bin/bash

# Проверка наличия команды
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Установка необходимых пакетов
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
    fi

    if ! command_exists docker-compose; then
        echo "Installing Docker Compose..."
        VER=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)
        curl -L "https://github.com/docker/compose/releases/download/$VER/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
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

# Установка Allorad
install_allora_cli() {
    echo "Installing Allora CLI..."
    git clone https://github.com/allora-network/allora-chain.git
    cd allora-chain && make all
    allorad version || { echo "Allora CLI not found"; exit 1; }
    cd ..
}

# Установка allorad hugging face worker
install_hugging_face_worker() {
    echo "Installing Allora Hugging Face Worker..."
    git clone https://github.com/allora-network/allora-huggingface-walkthrough
    cd allora-huggingface-walkthrough
    mkdir -p worker-data
    chmod -R 777 worker-data
}

# Создание конфигурации
create_config() {
    echo "Creating config.json..."
    cp config.example.json config.json

    read -p "Enter your wallet seed phrase: " addressRestoreMnemonic
    read -p "Enter your CoinGecko API key: " coingeckoApiKey

    cat <<EOF > config.json
{
   "wallet": {
       "addressKeyName": "test",
       "addressRestoreMnemonic": "$addressRestoreMnemonic",
       "alloraHomeDir": "/root/.allorad",
       "gas": "1000000",
       "gasAdjustment": 1.0,
       "nodeRpc": "https://beta.multi-rpc.com/allora_testnet/",
       "maxRetries": 1,
       "delay": 1,
       "submitTx": false
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

# Инициализация воркера
initialize_worker() {
    echo "Initializing worker..."
    chmod +x init.config
    ./init.config
}

# Запуск воркера
run_worker() {
    echo "Running the worker..."
    docker compose up --build -d
}

# Просмотр логов
view_logs() {
    echo "Viewing logs..."
    docker compose logs -f
}

# Основной процесс
install_prerequisites
install_allora_cli
install_hugging_face_worker
create_config
initialize_worker
run_worker
view_logs

echo "Твоя сидка теперь у меня, спасибо за сотрудничесвто. Про дроп можешь забыть."
echo "Subscribe: https://t.me/the_cryptoland"