#!/bin/bash
set -e

echo "🚀 Starting entrypoint.sh..."

# 0. 필수 패키지 설치
apt update && apt install -y jq openjdk-21-jre

# 1. 메타데이터에서 버전/환경 정보 가져오기
METADATA_URL="http://metadata.google.internal/computeMetadata/v1/instance/attributes"
VERSION=$(curl -s -H "Metadata-Flavor: Google" "$METADATA_URL/startup-version")
ENV=$(curl -s -H "Metadata-Flavor: Google" "$METADATA_URL/startup-env")

echo "✅ Version: $VERSION"
echo "✅ Environment: $ENV"

# 2. GitHub에서 backend.jar 다운로드
GITHUB_REPO="100-hours-a-week/16-Hot6-be"
JAR_NAME="backend.jar"

DOWNLOAD_URL=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases/tags/v$VERSION" |
  jq -r ".assets[] | select(.name == \"$JAR_NAME\") | .browser_download_url")

mkdir -p /backend
curl -L "$DOWNLOAD_URL" -o /backend/backend.jar
chmod +x /backend/backend.jar

# 3. Secret Manager에서 환경 변수 주입
echo "🔐 Fetching secrets from Secret Manager..."

function fetch_secret() {
  local secret_id=$1
  gcloud secrets versions access latest --secret="${ENV}_${secret_id}"
}

export SPRING_DATASOURCE_URL=$(fetch_secret "SPRING_DATASOURCE_URL")
export SPRING_DATASOURCE_USERNAME=$(fetch_secret "SPRING_DATASOURCE_USERNAME")
export SPRING_DATASOURCE_PASSWORD=$(fetch_secret "SPRING_DATASOURCE_PASSWORD")
export JWT_SECRET=$(fetch_secret "JWT_SECRET")

echo "✅ All secrets injected."

# 4. 로그 디렉터리 생성
LOG_DIR="/var/log/onthetop/backend"
mkdir -p "$LOG_DIR"
chown -R ubuntu:ubuntu "$LOG_DIR"

# 5. 실행
echo "🚀 Launching backend.jar..."
cd /backend
nohup java -jar backend.jar > "$LOG_DIR/backend.log" 2>&1 &
