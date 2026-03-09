class PillowDiagnosis < ApplicationRecord
  belongs_to :user

  validates :sleeping_position, presence: true
  validates :height, presence: true
  validates :material_preference, presence: true
  validates :order_interest, presence: true
  validates :price_range, presence: true
end
