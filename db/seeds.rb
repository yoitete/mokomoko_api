# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# 第1特集（メイン特集）の初期データ
primary_campaigns_data = [
  {
    name: 'クリスマス特集',
    description: '心まで温まる、クリスマス限定のふわもこ毛布',
    subtitle: '冬の夜をやさしく包み込む、とっておきのブランケットをご用意しました',
    color_theme: 'red',
    start_month: 12,
    end_month: 2,
    link_path: '/christmas',
    button_text: '詳しくはこちら →',
    highlight_text: '大切な人へのギフトにも、自分へのご褒美にもぴったり！',
    highlight_color: 'red',
    campaign_type: 'primary',
    active: true
  },
  {
    name: '母の日特集',
    description: 'お母さんに感謝を込めて、特別なふわもこ毛布',
    subtitle: '日頃の感謝の気持ちを込めて、心地よい温もりをお届けします',
    color_theme: 'pink',
    start_month: 3,
    end_month: 5,
    link_path: '/mothers-day',
    button_text: '詳しくはこちら →',
    highlight_text: 'お母さんへの特別な贈り物にぴったり！',
    highlight_color: 'pink',
    campaign_type: 'primary',
    active: true
  },
  {
    name: '夏でも快適！ひんやり毛布特集',
    description: '暑い夏でも心地よい、ひんやり感触の特別な毛布',
    subtitle: 'エアコンの効いた部屋で、快適な眠りをサポートします',
    color_theme: 'blue',
    start_month: 6,
    end_month: 8,
    link_path: '/summer-cool',
    button_text: '詳しくはこちら →',
    highlight_text: '夏の快適な睡眠をサポート！',
    highlight_color: 'blue',
    campaign_type: 'primary',
    active: true
  },
  {
    name: 'ハロウィン特集',
    description: '秋の夜長を楽しむ、ハロウィン限定デザインの毛布',
    subtitle: 'オレンジと黒の特別なデザインで、秋の雰囲気を演出',
    color_theme: 'orange',
    start_month: 9,
    end_month: 11,
    link_path: '/halloween',
    button_text: '詳しくはこちら →',
    highlight_text: 'ハロウィンの特別な夜にぴったり！',
    highlight_color: 'orange',
    campaign_type: 'primary',
    active: true
  }
]

# 第2特集（サブ特集）の初期データ
secondary_campaigns_data = [
  {
    name: '受験応援！あったか毛布特集',
    description: '合格への道を、あたたかさで支える',
    subtitle: '冬の受験勉強は、寒さとの戦いでもあります',
    color_theme: 'indigo',
    start_month: 12,
    end_month: 2,
    link_path: '/exam-support',
    button_text: '詳しくはこちら →',
    highlight_text: '集中力を高める、あなただけの学習パートナー',
    highlight_color: 'indigo',
    campaign_type: 'secondary',
    active: true
  },
  {
    name: '新生活応援特集',
    description: '新しいスタートを温かくサポート',
    subtitle: '新生活の始まりに、心地よい毛布で快適な環境を',
    color_theme: 'green',
    start_month: 3,
    end_month: 5,
    link_path: '/new-life-support',
    button_text: '詳しくはこちら →',
    highlight_text: '新生活を快適にスタート！',
    highlight_color: 'green',
    campaign_type: 'secondary',
    active: true
  },
  {
    name: '父の日ギフト特集',
    description: 'お父さんに感謝を込めて、上質な毛布を',
    subtitle: 'いつも家族を支えてくれるお父さんへの特別なギフト',
    color_theme: 'blue',
    start_month: 6,
    end_month: 8,
    link_path: '/fathers-day',
    button_text: '詳しくはこちら →',
    highlight_text: 'お父さんへの感謝の気持ちを形に',
    highlight_color: 'blue',
    campaign_type: 'secondary',
    active: true
  },
  {
    name: '秋のくつろぎ毛布特集',
    description: '秋の夜長をゆったりと過ごす、極上の毛布',
    subtitle: '読書や映画鑑賞のお供に、心地よいくつろぎタイムを',
    color_theme: 'yellow',
    start_month: 9,
    end_month: 11,
    link_path: '/autumn-relax',
    button_text: '詳しくはこちら →',
    highlight_text: '秋の夜長を特別な時間に',
    highlight_color: 'yellow',
    campaign_type: 'secondary',
    active: true
  }
]

puts "Creating seasonal campaigns..."

# 第1特集（primary）の作成・更新
puts "Creating primary campaigns..."
primary_campaigns_data.each do |campaign_data|
  campaign = SeasonalCampaign.find_or_initialize_by(
    campaign_type: 'primary',
    start_month: campaign_data[:start_month],
    end_month: campaign_data[:end_month]
  )
  
  campaign.assign_attributes(campaign_data)
  
  if campaign.save
    puts "✓ Created/Updated Primary: #{campaign.name} (#{campaign.start_month}月〜#{campaign.end_month}月)"
  else
    puts "✗ Failed to create Primary: #{campaign_data[:name]} - #{campaign.errors.full_messages.join(', ')}"
  end
end

# 第2特集（secondary）の作成・更新
puts "Creating secondary campaigns..."
secondary_campaigns_data.each do |campaign_data|
  campaign = SeasonalCampaign.find_or_initialize_by(
    campaign_type: 'secondary',
    start_month: campaign_data[:start_month],
    end_month: campaign_data[:end_month]
  )
  
  campaign.assign_attributes(campaign_data)
  
  if campaign.save
    puts "✓ Created/Updated Secondary: #{campaign.name} (#{campaign.start_month}月〜#{campaign.end_month}月)"
  else
    puts "✗ Failed to create Secondary: #{campaign_data[:name]} - #{campaign.errors.full_messages.join(', ')}"
  end
end

puts "Seasonal campaigns seeding completed!"
