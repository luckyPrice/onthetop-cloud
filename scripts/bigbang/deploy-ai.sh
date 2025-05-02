#!/bin/bash

set -e  # 에러 발생 시 즉시 종료

PROJECT_DIR="$HOME/ai-server"
VENV_DIR="$PROJECT_DIR/venv"
LOG_FILE="$PROJECT_DIR/ai.log"
APP_MODULE="pipeline_test.main:app"
PORT=8000

echo "▶️ [1] 프로젝트 디렉터리 이동 및 최신 코드 pull"
cd "$PROJECT_DIR" || exit
git pull origin dev

echo "▶️ [2] Python3 확인"
python3 --version

echo "▶️ [3] 가상환경 생성 (없으면 생성)"
if [ ! -d "$VENV_DIR" ]; then
  python3 -m venv "$VENV_DIR"
fi

echo "▶️ [4] 가상환경 활성화"
source "$VENV_DIR/bin/activate"

echo "▶️ [5] 의존성 설치"
pip install --upgrade pip
pip install -r requirements.txt

echo "▶️ [6] 실행 중인 FastAPI 프로세스 종료"
PID=$(pgrep -f "uvicorn .*${APP_MODULE}" || true)

if [ -n "$PID" ]; then
  echo "기존 프로세스 종료중 (PID: $PID)"
  kill "$PID"
  sleep 3
else
  echo "실행 중인 프로세스 없음"
fi

echo "▶️ [7] FastAPI 서버 백그라운드 실행 (port: $PORT)"
nohup uvicorn "$APP_MODULE" --host 0.0.0.0 --port "$PORT" > "$LOG_FILE" 2>&1 &

NEW_PID=$!
echo "✅ 새 프로세스 실행됨 (PID: $NEW_PID)"
echo "로그 파일: $LOG_FILE"

echo "🎉 AI 서버 배포 완료!"