class ThankYou < ApplicationRecord

  validates_presence_of :creator, :pizzas, :vendor, :video
  belongs_to :creator, class_name: "User", foreign_key: :creator_id

end
