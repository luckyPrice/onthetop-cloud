#!/bin/bash

echo "📦 Downloading and running entrypoint.sh from GitHub..."

curl -sSL https://raw.githubusercontent.com/100-hours-a-week/16-Hot6-cloud/feat/bluegreen-script/scripts/cicd/entrypoint.sh | bash
