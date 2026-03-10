class CommentsController < ApplicationController
  skip_before_action :authenticate_user, only: [:index]

  # GET /comments?post_id=:post_id
  def index
    @comments = Comment.where(post_id: params[:post_id])
                       .includes(:user)
                       .order(created_at: :asc)

    comments_data = @comments.map do |comment|
      {
        id: comment.id,
        user_id: comment.user_id,
        post_id: comment.post_id,
        body: comment.body,
        user_name: comment.user&.name,
        user_nickname: comment.user&.nickname,
        user_selected_icon: comment.user&.selected_icon,
        created_at: comment.created_at,
        updated_at: comment.updated_at
      }
    end

    render json: comments_data
  end

  # POST /comments
  def create
    @comment = Comment.new(
      user_id: @current_user.id,
      post_id: params[:post_id],
      body: params[:body]
    )

    if @comment.save
      render json: {
        message: "コメントを投稿しました",
        comment: {
          id: @comment.id,
          user_id: @comment.user_id,
          post_id: @comment.post_id,
          body: @comment.body,
          user_name: @current_user.name,
          user_nickname: @current_user.nickname,
          user_selected_icon: @current_user.selected_icon,
          created_at: @comment.created_at,
          updated_at: @comment.updated_at
        }
      }, status: :created
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /comments/:id
  def destroy
    @comment = Comment.find_by(id: params[:id], user_id: @current_user.id)

    if @comment
      @comment.destroy
      render json: { message: "コメントを削除しました" }
    else
      render json: { error: "コメントが見つかりません" }, status: :not_found
    end
  end
end
