class SeasonalCampaignsController < ApplicationController
  # 特集の表示は認証不要
  skip_before_action :authenticate_user, only: [ :current, :current_secondary, :active, :index, :show ]

  before_action :set_seasonal_campaign, only: [ :show, :update, :destroy ]

  # GET /seasonal_campaigns/current
  # 現在の月に適用される特集を取得
  def current
    campaign = SeasonalCampaign.current_campaign
    if campaign
      render json: campaign
    else
      render json: { error: "No active campaign found for current month" }, status: :not_found
    end
  end

  # GET /seasonal_campaigns/current_secondary
  # 現在の月に適用される第2特集を取得
  def current_secondary
    campaign = SeasonalCampaign.current_secondary_campaign
    if campaign
      render json: campaign
    else
      render json: { error: "No active secondary campaign found for current month" }, status: :not_found
    end
  end

  # GET /seasonal_campaigns/for_month/:month
  # 指定された月の特集を取得
  def for_month
    month = params[:month].to_i
    unless (1..12).include?(month)
      render json: { error: "Invalid month. Must be between 1 and 12" }, status: :bad_request
      return
    end

    campaign = SeasonalCampaign.campaign_for_month(month)
    if campaign
      render json: campaign
    else
      render json: { error: "No campaign found for month #{month}" }, status: :not_found
    end
  end

  # GET /seasonal_campaigns
  # 全ての特集を取得（管理用）
  def index
    campaigns = SeasonalCampaign.ordered
    render json: campaigns
  end

  # GET /seasonal_campaigns/active
  # 有効な特集をすべて取得
  def active
    campaigns = SeasonalCampaign.active.ordered
    render json: campaigns
  end

  # GET /seasonal_campaigns/:id
  # 特定の特集を取得
  def show
    render json: @seasonal_campaign
  end

  # POST /seasonal_campaigns
  # 新しい特集を作成（管理用）
  def create
    @seasonal_campaign = SeasonalCampaign.new(seasonal_campaign_params)

    if @seasonal_campaign.save
      render json: @seasonal_campaign, status: :created
    else
      render json: { errors: @seasonal_campaign.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /seasonal_campaigns/:id
  # 特集を更新（管理用）
  def update
    if @seasonal_campaign.update(seasonal_campaign_params)
      render json: @seasonal_campaign
    else
      render json: { errors: @seasonal_campaign.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /seasonal_campaigns/:id
  # 特集を削除（管理用）
  def destroy
    @seasonal_campaign.destroy
    head :no_content
  end

  private

  def set_seasonal_campaign
    @seasonal_campaign = SeasonalCampaign.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Seasonal campaign not found" }, status: :not_found
  end

  def seasonal_campaign_params
    params.require(:seasonal_campaign).permit(
      :name, :description, :subtitle, :color_theme,
      :start_month, :end_month, :link_path, :button_text,
      :highlight_text, :highlight_color, :active, :campaign_type
    )
  end
end
