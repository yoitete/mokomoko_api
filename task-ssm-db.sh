#! /bin/bash

# ログイン
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin $(aws sts get-caller-identity --query Account --output text).dkr.ecr.ap-northeast-1.amazonaws.com
# タスクIDの取得
TASK_ID=$(aws ecs list-tasks \
    --cluster mokomoko_cluster \
    --service-name mokomoko_service \
    --query "taskArns[0]" \
    --output text | cut -d "/" -f3)

if [ -z "$TASK_ID" ]; then
    echo "Error: Task ID not found"
    exit 1
fi

# コンテナランタイムIDの取得（apiコンテナ）
CONTAINER_RUNTIME_ID=$(aws ecs describe-tasks \
    --cluster mokomoko_cluster \
    --tasks $TASK_ID \
    --query "tasks[0].containers[?name=='api'].runtimeId" \
    --output text)

if [ -z "$CONTAINER_RUNTIME_ID" ]; then
    echo "Error: Container runtime ID not found"
    exit 1
fi

echo "Task ID: $TASK_ID"
echo "Container Runtime ID: $CONTAINER_RUNTIME_ID"
echo "Port: 13306"

echo "command + C で終了します"

# SSMセッションの開始
aws ssm start-session \
    --target ecs:mokomoko_cluster_${TASK_ID}_${CONTAINER_RUNTIME_ID} \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters "{\"host\":[\"mokomoko-rds.cvu288qmotse.ap-northeast-1.rds.amazonaws.com\"],\"portNumber\":[\"3306\"],\"localPortNumber\":[\"13306\"]}"
