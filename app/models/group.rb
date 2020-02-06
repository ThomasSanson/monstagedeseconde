class Group < ApplicationRecord
  scope :is_public, lambda { where(is_public: true) }
  scope :is_private, lambda { where(is_public: false) }
  has_many :internship_offers
end
