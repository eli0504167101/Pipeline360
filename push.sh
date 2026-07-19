#!/bin/bash

set -e

CURRENT_BRANCH=$(git branch --show-current)

if [ "$CURRENT_BRANCH" != "dev" ]; then
    echo "שגיאה: יש להריץ את הסקריפט רק מענף dev."
    echo "הענף הנוכחי הוא: $CURRENT_BRANCH"
    exit 1
fi

git add .

if git diff --cached --quiet; then
    echo "אין שינויים חדשים לביצוע commit."
    exit 0
fi

git commit -m "Update CI/CD pipeline"
git push origin dev

echo "השינויים נדחפו בהצלחה ל-dev."
echo "GitHub Actions יעדכן את deploy-dev אוטומטית."