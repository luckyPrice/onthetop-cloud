#!/bin/bash

set -e  # 에러 발생 시 즉시 종료

PROJECT_DIR="$HOME/backend"
JAR_DIR="$PROJECT_DIR/build/libs"
DEPLOY_JAR="$PROJECT_DIR/backend-latest.jar"
PROFILE="dev"
SECRETS_PATH="$PROJECT_DIR/src/main/resources/secrets.properties"

echo "▶️ [1] 프로젝트 디렉터리 이동 및 최신 코드 pull"
cd "$PROJECT_DIR" || exit
git pull origin dev

echo "▶️ [2] Java 확인"
java -version

echo "▶️ [3] Gradle 빌드 실행"
chmod +x ./gradlew
./gradlew clean build -x test

echo "▶️ [4] 실행 중인 애플리케이션 중지"
PID=$(pgrep -f "$DEPLOY_JAR" || true)

if [ -n "$PID" ]; then
  echo "기존 프로세스 종료중 (PID: $PID)"
  kill "$PID"
  sleep 5
else
  echo "실행 중인 프로세스 없음"
fi

echo "▶️ [5] 새로운 JAR 준비"
JAR_FILE=$(ls "$JAR_DIR"/*.jar | grep -v plain | head -n 1)

if [ ! -f "$JAR_FILE" ]; then
  echo "⚠️  실행 가능한 JAR 파일이 없습니다. 빌드 실패."
  exit 1
fi

echo "사용할 JAR 파일: $JAR_FILE"
cp "$JAR_FILE" "$DEPLOY_JAR"

echo "▶️ [6] 새로운 JAR 실행"
nohup java -jar "$DEPLOY_JAR" \
  --spring.profiles.active="$PROFILE" \
  --spring.config.additional-location=file:$SECRETS_PATH \
  > "$PROJECT_DIR/app.log" 2>&1 &

NEW_PID=$!
echo "✅ 새 프로세스 실행됨 (PID: $NEW_PID)"
echo "로그 파일: $PROJECT_DIR/app.log"

echo "▶️ [7] 기동 상태 확인 (10초 후 로그 확인)"
sleep 10
tail -n 100 "$PROJECT_DIR/app.log"

echo "🎉 BE 배포 완료!"
