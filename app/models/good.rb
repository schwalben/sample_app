class Good < ApplicationRecord
  belongs_to :created_by, class_name: "User"
  belongs_to :micropost, class_name: "Micropost"
  counter_culture :micropost, class_name: "Micropost"
  
  validates :created_by, presence: true
  validates :micropost_id, presence: true
  
  default_scope -> { order(created_at: :desc) }
end
