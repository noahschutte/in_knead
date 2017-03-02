class User < ApplicationRecord

  validates_presence_of :fb_userID
  validates_uniqueness_of :fb_userID
  validates_format_of :signup_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create
  validates_format_of :current_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :update

  has_many :requests, class_name: "Request", foreign_key: :creator_id
  has_many :thank_yous, class_name: "ThankYou", foreign_key: :creator_id

  def self.recent_request(user_id)
    Request.where(creator: user_id).where("created_at > ?", DateTime.now - 1.days)[0]
  end

  def self.recent_successful_request(user_id)
    Request.where(creator: user_id).where.not(donor_id: nil).where("created_at > ?", DateTime.now - 14.days)[0]
  end

  def self.recent_successful_requests(user_id)
    Request.where(creator_id: user_id).where.not(donor_id: nil).where(status: "active")
  end

  # This fails if Request was reported, causing the updated_at to change
  def self.recent_donation(user_id)
    Request.where(donor_id: user_id).where.not(status: "received").where("updated_at > ?", DateTime.now - 30.minutes)[0]
  end

  def self.recent_donations(user_id)
    Request.where(donor_id: user_id).where.not(status: "received").map { |request|
      anon_email = User.find(request.creator_id).current_email
      seconds = (Time.now() - request.created_at).round
      {
        id: request.id,
        type: "request",
        creatorId: request.creator_id,
        anonEmail: anon_email,
        pizzas: request.pizzas,
        vendor: request.vendor,
        compressedVideo: get_compressed_url(request.video),
        thumbnail: get_thumbnail_url(request.video),
        donorId: request.donor_id,
        seconds: seconds,
        status: request.status,
        reports: request.reports,
        createdAt: request.created_at,
        updatedAt: request.updated_at
      }
    }
  end

  # Requests you've received but have not sent a Thank You for
  def self.thank_you_reminders(user_id)
    requests = Request.where(creator: user_id).where(status: "received")
    thank_yous = ThankYou.where(creator: user_id)
    collection = []
    requests.each { |request|
      match = false
      thank_yous.each { |thank_you|
        if request.id == thank_you.request_id
          match = true
        end
      }
      if match == false
        collection << request
      end
    }
    return collection
  end

  # Requests you donated to that do not have a Thank You
  def self.awaiting_thank_yous(user_id)
    requests = Request.where(donor_id: user_id).where(status: "received")
    thank_yous = ThankYou.where(donor_id: user_id).where(donor_viewed: false)
    collection = []
    requests.each { |request|
      match = false
      thank_yous.each { |thank_you|
        if request.id == thank_you.request_id
          match = true
        end
      }
      if match == false
        collection << request
      end
    }
    return collection
  end

  def self.received_thank_yous(user_id)
    ThankYou.where(donor_id: user_id).where(donor_viewed: false).where(transcoded: true)
  end

  private
    def self.get_compressed_url(video)
      @asset = S3_REQUESTS_COMPRESSED.object("transcoded/#{video}.mp4")
      @url = @asset.presigned_url(:get)
    end

    def self.get_thumbnail_url(video)
      @asset = S3_REQUESTS_THUMBNAILS.object("transcoded/#{video}-00001.png")
      @url = @asset.presigned_url(:get)
    end

end
