class ApplicationController < ActionController::API
    before_action :authenticate_user

    private

    # ユーザー認証
    def authenticate_user
      # リクエストヘッダーからJWTトークンを取得
      token = request.headers["Authorization"]&.sub(/^Bearer /, "")

      Rails.logger.info "Authentication attempt:"
      Rails.logger.info "  - Authorization header present: #{request.headers['Authorization'].present?}"
      Rails.logger.info "  - Token present: #{token.present?}"
      Rails.logger.info "  - Token length: #{token&.length || 0}"

      # tokenが存在しているかどうか確認する(空のことがあるので)
      if token.present?
        begin
          payload, header = JWT.decode(token, nil, false)
          Rails.logger.info "  - JWT payload decoded successfully"
          Rails.logger.info "  - Issuer: #{payload['iss']}"
          Rails.logger.info "  - User ID: #{payload['user_id']}"

          if payload["iss"] == "https://securetoken.google.com/mokomoko-2ac26"
            # ユーザーIDからユーザーを取得
            user = User.find_by(firebase_uid: payload["user_id"])
            Rails.logger.info "  - User found: #{user.present?}"
            Rails.logger.info "  - User ID: #{user&.id}"

            # ユーザーが存在しているかどうか確認する
            if user.present?
              # ユーザーが存在していれば@current_userに代入する
              @current_user = user
              Rails.logger.info "  - Authentication successful"
            else
              Rails.logger.warn "  - User not found in database"
              Rails.logger.warn "  - Firebase UID: #{payload['user_id']}"
              Rails.logger.warn "  - This user needs to complete registration"
            end
          else
            Rails.logger.warn "  - Invalid issuer: #{payload['iss']}"
          end
        rescue JWT::DecodeError => e
          Rails.logger.error "  - JWT decode error: #{e.message}"
        rescue => e
          Rails.logger.error "  - Authentication error: #{e.message}"
        end
      else
        Rails.logger.warn "  - No token provided"
      end

      # 認証失敗
      unless @current_user
        Rails.logger.warn "  - Authentication failed - returning 401"
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end
end
