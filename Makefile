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

# RSpecテストを実行(基本これを使っていく予定)
.PHONY: test
test:
	docker compose run --rm -e RAILS_ENV=test -e MYSQL_USER=root -e MYSQL_PASSWORD=password -e MYSQL_DATABASE=database_test -e MYSQL_DATABASE_TEST=database_test -e MYSQL_HOST=db -e MYSQL_PORT=3306 api bash -c "bin/rails db:environment:set RAILS_ENV=test && bin/rails db:test:prepare && bundle exec rspec"

# テストデータベースを準備
.PHONY: test-prepare
test-prepare:
	docker compose run --rm -e RAILS_ENV=test -e MYSQL_USER=root -e MYSQL_PASSWORD=password -e MYSQL_DATABASE=database_test -e MYSQL_DATABASE_TEST=database_test -e MYSQL_HOST=db -e MYSQL_PORT=3306 api bash -c "bin/rails db:environment:set RAILS_ENV=test && bin/rails db:test:prepare"

# RSpecテストのみ実行（データベース準備済みの場合）
.PHONY: test-only
test-only:
	docker compose run --rm -e RAILS_ENV=test -e MYSQL_USER=root -e MYSQL_PASSWORD=password -e MYSQL_DATABASE=database_test -e MYSQL_DATABASE_TEST=database_test -e MYSQL_HOST=db -e MYSQL_PORT=3306 api bundle exec rspec

# SSMセッションを開始
.PHONY: ssm-session
ssm-session:
	chmod +x task-ssm-db.sh
	./task-ssm-db.sh
