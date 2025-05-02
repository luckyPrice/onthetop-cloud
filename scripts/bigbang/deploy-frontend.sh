#!/bin/bash

set -e  # 에러 발생 시 즉시 종료

# 배포 변수

PROJECT_DIR="$HOME/frontend/ott"
BUILD_DIR="$PROJECT_DIR/dist"
DEPLOY_DIR="/var/www/html"

echo "▶️ [1] 프로젝트 디렉터리 이동 및 최신 코드 pull"
cd "$PROJECT_DIR" || exit
git pull origin dev

echo "▶️ [2] Node.js 버전 확인 (nvm은 사전 설치 필요)"
node -v
yarn -v

echo "▶️ [3] 의존성 설치"
yarn install

# echo "▶️ [4] 환경 변수 설정"
# cp .env.production .env

echo "▶️ [5] 정적 빌드"
yarn build

echo "▶️ [6] Nginx 배포 디렉터리 초기화"
sudo rm -rf "$DEPLOY_DIR"/*
sudo mkdir -p "$DEPLOY_DIR"

echo "▶️ [7] 빌드 파일 복사"
sudo cp -r "$BUILD_DIR"/* "$DEPLOY_DIR"

echo "✅ 배포 완료: $DEPLOY_DIR 에 빌드 파일이 배포되었습니다."

echo "▶️ [8] Nginx Reload (Optional)"
sudo systemctl reload nginx

echo "🎉 All Done."