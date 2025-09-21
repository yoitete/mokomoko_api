class SeasonalCampaign < ApplicationRecord
  validates :name, presence: true
  validates :start_month, presence: true, inclusion: { in: 1..12 }
  validates :end_month, presence: true, inclusion: { in: 1..12 }
  validates :link_path, presence: true
  validates :color_theme, presence: true, inclusion: { 
    in: %w[red pink blue orange green purple yellow indigo] 
  }
  validates :campaign_type, presence: true, inclusion: { 
    in: %w[primary secondary] 
  }
  
  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:start_month) }
  scope :primary, -> { where(campaign_type: 'primary') }
  scope :secondary, -> { where(campaign_type: 'secondary') }
  
  # 現在の月に適用される特集を取得
  def self.current_campaign
    current_month = Date.current.month
    
    # 12月から2月の場合（年をまたぐ）
    if current_month == 12 || current_month <= 2
      campaign = active.primary.where(
        "(start_month = 12 AND end_month <= 2) OR (start_month <= ? AND end_month >= ?)",
        current_month, current_month
      ).first
      
      # 年をまたぐ特集がない場合、12月開始の特集を探す
      campaign ||= active.primary.where(start_month: 12).first if current_month == 12
      campaign ||= active.primary.where(end_month: 1..2).first if current_month <= 2
    else
      campaign = active.primary.where("start_month <= ? AND end_month >= ?", current_month, current_month).first
    end
    
    campaign
  end
  
  # 現在の月に適用される第2特集を取得
  def self.current_secondary_campaign
    current_month = Date.current.month
    
    # 12月から2月の場合（年をまたぐ）
    if current_month == 12 || current_month <= 2
      campaign = active.secondary.where(
        "(start_month = 12 AND end_month <= 2) OR (start_month <= ? AND end_month >= ?)",
        current_month, current_month
      ).first
      
      # 年をまたぐ特集がない場合、12月開始の特集を探す
      campaign ||= active.secondary.where(start_month: 12).first if current_month == 12
      campaign ||= active.secondary.where(end_month: 1..2).first if current_month <= 2
    else
      campaign = active.secondary.where("start_month <= ? AND end_month >= ?", current_month, current_month).first
    end
    
    campaign
  end
  
  # 指定された月に適用される特集を取得
  def self.campaign_for_month(month)
    month = month.to_i
    return nil unless (1..12).include?(month)
    
    if month == 12 || month <= 2
      campaign = active.where(
        "(start_month = 12 AND end_month <= 2) OR (start_month <= ? AND end_month >= ?)",
        month, month
      ).first
      
      campaign ||= active.where(start_month: 12).first if month == 12
      campaign ||= active.where(end_month: 1..2).first if month <= 2
    else
      campaign = active.where("start_month <= ? AND end_month >= ?", month, month).first
    end
    
    campaign
  end
  
  # 特集が現在アクティブかどうか
  def current?
    return false unless active?
    
    current_month = Date.current.month
    
    if start_month == 12 && end_month <= 2
      # 年をまたぐ特集
      current_month == 12 || current_month <= end_month
    else
      # 通常の特集
      current_month >= start_month && current_month <= end_month
    end
  end
  
  # 特集期間の表示用文字列
  def period_display
    if start_month == 12 && end_month <= 2
      "12月〜#{end_month}月"
    else
      "#{start_month}月〜#{end_month}月"
    end
  end
end
