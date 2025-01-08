#!/bin/bash



function stop_all() {
    # 停止所有运行中的容器
    docker stop "$(docker ps -q)"
}

function start_all() {
    # 启动所有停止的容器
    docker start "$(docker ps -aq)"
}

function remove_all() {
    # 删除所有容器
    docker rm "$(docker ps -aq)"
}

function remove_exited() {
	# 删除所有停止的容器
	docker rm "$(docker ps -aq -f "status=exited")"
}


function remove_dangling() {
    # 删除dangling 镜像
    docker rmi "$(docker images -q -f "dangling=true")"
}

function backup_container() {
	# 备份容器的数据
  CONTAINER_ID=$1
  BACKUP_FILE="${CONTAINER_ID}_backup_$(date +%F).tar"
  docker export "$CONTAINER_ID" > "$BACKUP_FILE"
  echo "备份保存到 $BACKUP_FILE"
}

function restore_container() {
	# 恢复容器的数据
	CONTAINER_ID=$1
  BACKUP_FILE=$2
  docker import "$BACKUP_FILE" "$CONTAINER_ID"
  echo "容器 $CONTAINER_ID 已恢复"
}

function state() {
    # 监控所有运行中容器的资源使用情况
    docker stats --all
}

function auto_restart() {
#    # 自动重启容器
#    docker ps -q | xargs -I {} docker inspect {} --format '{{.State.Status}}' | grep -v running | awk '{print $1}' | xargs -I {} docker restart {}
    # 使用重启策略重启容器
    CONTAINER_NAME=$1
    docker update --restart always "$CONTAINER_NAME"
    echo "$CONTAINER_NAME 现在将在失败后自动重启。"
}

function run_image_and_clean() {
    # 运行容器并清理
    IMAGE_NAME=$1
    docker run --rm "$IMAGE_NAME"
}

function all_logs() {
    # 显示所有容器的日志
    docker ps -q | xargs -I {} docker logs {}
}

function cleanup_volumes() {
    # 清理未使用的资源
    docker system prune -f --volumes
}

function update_container() {
    # 更新运行中的容器
    CONTAINER_NAME=$1
    IMAGE_NAME=$(docker inspect --format='{{.Config.Image}}' "$CONTAINER_NAME")
    docker pull "$IMAGE_NAME"
    docker stop "$CONTAINER_NAME"
    docker rm "$CONTAINER_NAME"
    docker run -d --name "$CONTAINER_NAME" "$IMAGE_NAME"
}

function copy_file() {
    # 从容器复制文件
    CONTAINER_ID=$1
    SOURCE_PATH=$2
    DEST_PATH=$3
    docker cp "$CONTAINER_ID":"$SOURCE_PATH" "$DEST_PATH"
    echo "从 $CONTAINER_ID 复制 $SOURCE_PATH 到 $DEST_PATH"
}

function restart_all(){
	# 重启所有容器
  docker restart "$(docker ps -q)"
}

function show_export_ports() {
    # 列出所有暴露的端口
    docker ps --format '{{.ID}}: {{.Ports}}'
}

function main() {
		# 主函数
		if [ "$1" == "start" ]; then
				start_all
		elif [ "$1" == "stop" ]; then
				stop_all
		elif [ "$1" == "remove" ]; then
				remove_all
		elif [ "$1" == "remove-exited" ]; then
				remove_exited
		elif [ "$1" == "remove-dangling" ]; then
				remove_dangling
		elif [ "$1" == "backup" ]; then
				backup_container "$2"
		elif [ "$1" == "restore" ]; then
				restore_container "$2" "$3"
		elif [ "$1" == "state" ]; then
				state
		elif [ "$1" == "auto-restart" ]; then
				auto_restart "$2"
		elif [ "$1" == "run" ]; then
				run_image_and_clean "$2"
		elif [ "$1" == "logs" ]; then
				all_logs
		elif [ "$1" == "cleanup" ]; then
				cleanup_volumes
		elif [ "$1" == "update" ]; then
				update_container "$2"
		elif [ "$1" == "copy" ]; then
				copy_file "$2" "$3" "$4"
		elif [ "$1" == "restart" ]; then
				restart_all
		elif [ "$1" == "ports" ]; then
				show_export_ports
		fi
}

main "$@"