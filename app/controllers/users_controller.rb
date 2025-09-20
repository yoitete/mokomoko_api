class UsersController < ApplicationController
  # before_action :set_user, only: %i[ show update destroy ]
  skip_before_action :authenticate_user

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    @user = User.find(params[:id])
    render json: @user
  end

  # GET /users/by_firebase_uid/:firebase_uid
  def show_by_firebase_uid
    @user = User.find_by(firebase_uid: params[:firebase_uid])
    if @user
      render json: @user
    else
      render json: { error: "User not found" }, status: :not_found
    end
  end

  # POST /users
  def create
    @user = User.new()
    token = user_params[:token]
    puts "--------------------------------"
    puts "token: #{token}"
    puts "name: #{user_params[:name]}"
    puts "--------------------------------"
    @user.name = user_params[:name]

    # tokenが存在しているかどうか確認する(空のことがあるので)
    if token.present?
      payload, header = JWT.decode(token, nil, false)
      if payload["iss"] == "https://securetoken.google.com/mokomoko-2ac26"
        @user.firebase_uid = payload["user_id"]
        if @user.save
          render json: @user.id.to_json, status: :created
          return
        end
      end
    end

    render json: { error: "Invalid token" }, status: :unprocessable_entity
  end

  # PATCH/PUT /users/1
  def update
    @user = User.find(params[:id])
    
    # パラメータの種類に応じて適切なパラメータを使用
    update_params = if params[:profile].present?
                      profile_params
                    elsif params[:user].present?
                      user_info_params
                    else
                      {}
                    end
    
    if @user.update(update_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # # DELETE /users/1
  # def destroy
  #   @user.destroy!
  # end

  private
  # Use callbacks to share common setup or constraints between actions.
  # def set_user
  #   @user = User.find(params.expect(:id))
  # end

  # Only allow a list of trusted parameters through.
  def user_params
    params.permit(:name, :token)
  end

  # Profile update parameters
  def profile_params
    params.require(:profile).permit(:nickname, :bio, :profile_image, :selected_icon)
  end

  # User info update parameters (for settings page)
  def user_info_params
    params.require(:user).permit(:name, :nickname, :bio, :profile_image, :selected_icon)
  end
end
