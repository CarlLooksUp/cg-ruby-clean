class NameObject < ActiveRecord::Base
  # fields: likes, name
  belongs_to :user
  belongs_to :nameable, polymorphic: true

  has_many :transactions

  validates :name, presence: true

  scope :businesses, -> { where(nameable_type: "Business") }
  scope :owned_by, ->(user_id) { where(user_id: user_id) }
end
