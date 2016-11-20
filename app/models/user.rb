class User < ApplicationRecord

    validates_presence_of :fb_userID
    validates_uniqueness_of :fb_userID, :signup_email, :current_email
    validates_format_of :signup_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
    validates_format_of :current_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

    has_many :requests, class_name: "Request", foreign_key: :creator_id

    def self.recent_request(user_id)
      return true if Request.where(creator: user_id).where("created_at > ?", DateTime.now - 1.days).any?
      false
    end

    def self.recent_successful_request(user_id)
      return true if Request.where(creator: user_id).where("created_at > ?", DateTime.now - 14.days).where.not(donor_id: nil).any?
      false
    end

    def self.recent_donation(user_id)
      return true if Request.where(donor_id: user_id).where("updated_at > ?", DateTime.now - 30.minutes).any?
      false
    end

end
