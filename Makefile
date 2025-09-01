# サーバー起動
# make server-up
.PHONY: server-up
server-up:
	docker compose up

# サーバー停止
# make server-stop
.PHONY: server-stop
server-stop:
	docker compose stop

# サーバー削除
# make server-down
.PHONY: server-down
server-down:
	docker compose down

# サーバー再起動
# make server-restart
.PHONY: server-restart
server-restart:
	docker compose restart

# コンテナに入る
.PHONY: server-enter
server-enter:
	docker compose run --rm api bash
