class User < ApplicationRecord

    validates_presence_of :fb_userID
    validates_uniqueness_of :fb_userID
    validates_format_of :current_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :update

    has_many :requests, class_name: "Request", foreign_key: :creator_id
    has_many :thank_yous, class_name: "ThankYou", foreign_key: :creator_id

    def self.recent_request(user_id)
      Request.where(creator: user_id).where("created_at > ?", DateTime.now - 1.days)[0]
    end

    def self.recent_successful_request(user_id)
      Request.where(creator: user_id).where("created_at > ?", DateTime.now - 14.days).where.not(donor_id: nil)[0]
    end

    def self.recent_thank_you(user_id)
      ThankYou.where(creator: user_id).order('created_at DESC')[0]
    end

    # Recent donation collects most recently updated request
      # Updated_at changes with reports
    def self.recent_donation(user_id)
      Request.where(donor_id: user_id).where("updated_at > ?", DateTime.now - 30.minutes)[0]
    end

    # Received thank you only returns 1 and not an array
    def self.received_thank_you(user_id)
      ThankYou.where(donor_id: user_id).where(donor_viewed: false).order('updated_at DESC')[0]
    end

    # Left Join Requests and ThankYous
    def self.awaiting_thank_yous(user_id)
      requests = Request.where(donor_id: user_id).where(status: "received")
      thank_yous = ThankYou.where(donor_id: user_id).where(donor_viewed: false)
      requests.reject { |request|
        thank_yous.map { |thank_you|
          p "request id:"
          p request.id
          p "thank you id:"
          p thank_you.request_id
          request.id == thank_you.request_id
        }
      }
      p "requests"
      p requests
      return requests
    end

end
