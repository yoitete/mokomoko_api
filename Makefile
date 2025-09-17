# サーバー起動
# make up
.PHONY: up
up:
	docker compose up

# サーバー停止
# make stop
.PHONY: stop
stop:
	docker compose stop

# サーバー削除
# make down
.PHONY: down
down:
	docker compose down

# サーバー再起動
# make restart
.PHONY: restart
restart:
	docker compose restart

# コンテナに入る
# make enter
.PHONY: enter
enter:
	docker compose run --rm api bash

# rubocopを実行(自動修正なし)
.PHONY: rubocop
rubocop:
	docker compose run --rm api bundle exec rubocop

# rubocopを使って自動修正
.PHONY: rubocop-fix
rubocop-fix:
	docker compose run --rm api bundle exec rubocop -A
