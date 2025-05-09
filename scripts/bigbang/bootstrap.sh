#!/bin/bash

set -e  # 에러 발생 시 중단

echo "▶️ [1] 필수 패키지 설치 (git, curl, vim 등)"
sudo apt update
sudo apt install -y git curl vim build-essential

echo "▶️ [2] Java 설치 (OpenJDK 21)"
sudo apt install -y openjdk-21-jdk
java -version

echo "▶️ [3] Python + pip + FastAPI 용 패키지 설치"
sudo apt install -y python3 python3-pip python3-venv

echo "▶️ [4] FastAPI 관련 패키지 설치 (uvicorn 포함)"
pip3 install fastapi uvicorn

echo "▶️ [5] nvm 설치 및 Node.js + yarn 설치"
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

# nvm 환경 재적용
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

nvm install --lts
nvm alias default lts/*
nvm use default

npm install -g yarn

echo "▶️ [6] 설치 확인"
git --version
vim --version
java -version
python3 --version
pip3 --version
node -v
yarn -v
uvicorn --version

echo "🎉 서버 초기 설정 완료!"
