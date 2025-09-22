class PostsController < ApplicationController
  before_action :set_post, only: %i[ show update destroy ]
  skip_before_action :authenticate_user, only: [ :index, :show, :popular ]

  # GET /posts
  def index
    @posts = Post.includes(:tags)
    
    # ソートパラメータに応じて並び替え
    case params[:sort]
    when 'popular'
      @posts = @posts.popular
    when 'newest'
      @posts = @posts.order(created_at: :desc)
    else
      @posts = @posts.order(created_at: :desc) # デフォルトは新着順
    end

    posts_data = @posts.map do |post|
      Rails.logger.info "Post #{post.id}: images.attached? = #{post.images.attached?}, count = #{post.images.count}"
      images = if post.images.attached?
        post.images.map { |image| Rails.application.routes.url_helpers.rails_blob_url(image) }
      else
        []
      end
      Rails.logger.info "Post #{post.id}: images = #{images}"

      {
        id: post.id,
        user_id: post.user_id,
        title: post.title,
        price: post.price,
        description: post.description,
        season: post.season,
        tags: post.tags.pluck(:name),
        favorites_count: post.favorites_count,
        created_at: post.created_at,
        updated_at: post.updated_at,
        images: images
      }
    end

    render json: posts_data
  end

  # GET /posts/my
  def my
    @posts = Post.includes(:tags).where(user_id: @current_user.id).order(created_at: :desc)
    
    posts_data = @posts.map do |post|
      images = if post.images.attached?
        post.images.map { |image| Rails.application.routes.url_helpers.rails_blob_url(image) }
      else
        []
      end

      {
        id: post.id,
        user_id: post.user_id,
        title: post.title,
        price: post.price,
        description: post.description,
        season: post.season,
        tags: post.tags.pluck(:name),
        favorites_count: post.favorites_count,
        created_at: post.created_at,
        updated_at: post.updated_at,
        images: images
      }
    end

    render json: posts_data
  end

  # GET /posts/popular
  def popular
    # お気に入りが1件以上の投稿のみを対象
    @posts = Post.includes(:tags).where('favorites_count > 0').popular
    
    if params[:season].present?
      case params[:season]
      when 'spring-summer'
        @posts = @posts.where(season: ['spring-summer', 'spring', 'summer'])
      when 'autumn-winter'
        @posts = @posts.where(season: ['autumn-winter', 'autumn', 'winter'])
      else
        @posts = @posts.where(season: params[:season])
      end
    end

    # 画像がある投稿のみ（オプション）
    if params[:with_images] == 'true'
      @posts = @posts.joins(:images_attachments).distinct
    end

    # 件数制限
    limit = params[:limit] ? params[:limit].to_i : 10
    @posts = @posts.limit(limit)

    posts_data = @posts.map do |post|
      images = if post.images.attached?
        post.images.map { |image| Rails.application.routes.url_helpers.rails_blob_url(image) }
      else
        []
      end

      {
        id: post.id,
        user_id: post.user_id,
        title: post.title,
        price: post.price,
        description: post.description,
        season: post.season,
        tags: post.tags.pluck(:name),
        favorites_count: post.favorites_count,
        created_at: post.created_at,
        updated_at: post.updated_at,
        images: images
      }
    end

    render json: posts_data
  end

  # GET /posts/1
  def show
    render json: @post.as_json.merge(
      images: @post.images.attached? ? @post.images.map { |image| Rails.application.routes.url_helpers.rails_blob_url(image) } : [],
      tags: @post.tags.pluck(:name),
      favorites_count: @post.favorites_count
    )
  end

  # POST /posts
  def create
    @post = Post.new(post_params.except(:tags))
    @post.user_id = @current_user.id

    if @post.save
      # タグを個別に作成（重複を避ける）
      if params[:post][:tags].present?
        unique_tags = params[:post][:tags].uniq.reject(&:blank?).map(&:strip)
        unique_tags.each do |tag_name|
          @post.tags.find_or_create_by(name: tag_name) if tag_name.present?
        end
      end

      render json: @post.as_json.merge(
        images: @post.images.attached? ? @post.images.map { |image| Rails.application.routes.url_helpers.rails_blob_url(image) } : [],
        tags: @post.tags.pluck(:name)
      ), status: :created
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/1
  def update
    if @post.update(post_params.except(:tags))
      # 既存のタグを削除
      @post.tags.destroy_all
      @post.user_id = @current_user.id
      # 新しいタグを作成（重複を避ける）
      if params[:post][:tags].present?
        unique_tags = params[:post][:tags].uniq.reject(&:blank?).map(&:strip)
        unique_tags.each do |tag_name|
          @post.tags.find_or_create_by(name: tag_name) if tag_name.present?
        end
      end

      render json: @post.as_json.merge(
        images: @post.images.attached? ? @post.images.map { |image| Rails.application.routes.url_helpers.rails_blob_url(image) } : [],
        tags: @post.tags.pluck(:name)
      )
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # DELETE /posts/1
  def destroy
    if @post.user_id == @current_user.id
      @post.destroy!
      render json: { message: "Post deleted successfully" }, status: :ok
    else
      render json: { error: "You are not authorized to delete this post" }, status: :unauthorized
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.expect(post: [ :title, :price, :description, :season, :tags, images: [] ])
    end
end
