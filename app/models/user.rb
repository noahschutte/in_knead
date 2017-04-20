class User < ApplicationRecord

  validates_presence_of :fb_userID
  validates_uniqueness_of :fb_userID
  validates_format_of :signup_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create
  validates_format_of :current_email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :update, :allow_blank => true

  has_many :requests, class_name: "Request", foreign_key: :creator_id
  has_many :thank_yous, class_name: "ThankYou", foreign_key: :creator_id

  def self.recent_request(user_id)
    Request.where(creator: user_id).where.not(status: "deleted").where("created_at > ?", DateTime.now - 1.days)[0]
  end

  def self.recent_successful_request(user_id)
    Request.where(creator: user_id).where.not(donor_id: nil).where("created_at > ?", DateTime.now - 14.days)[0]
  end

  def self.recent_successful_requests(user_id)
    Request.where(creator_id: user_id).where.not(donor_id: nil).where(status: "active")
  end

  # Has the user reported this request?
  def self.reported_request(user, request)
    user.reported_requests.map { |reported_request|
      return true if reported_request == request.id
    }
    return false
  end

  # Has the user blocked this request's creator?
  def self.blocked_user(user, request)
    user.blocked.map { |blocked_user|
      return true if blocked_user == request.creator.id
    }
    return false
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

  # Donations you've received but have not sent a Thank You for
  def self.thank_you_reminders(user_id)
    requests = Request.where(creator: user_id, status: "received")
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
    requests = Request.where(donor_id: user_id, status: "received")
    thank_yous = ThankYou.where(donor_id: user_id, donor_viewed: false)
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
    ThankYou.where(donor_id: user_id, donor_viewed: false, transcoded: true)
  end

  def self.report_request(user_id, request_id)
    @user = User.find(user_id)
    @user.reported_requests << request_id
    @user.save
  end

  def self.report_thank_you(user_id, thank_you_id)
    @user = User.find(user_id)
    @user.reported_thank_yous << thank_you_id
    @user.save
  end

  def self.block(user_id, block_user_id)
    @user = User.find(user_id)
    @user.blocked << block_user_id
    @user.save
  end

  def self.banned(user_id)
    requests = Request.where(creator: user_id, removed: true).count
    thank_yous = ThankYou.where(creator: user_id, removed: true).count
    requests + thank_yous > 1 ? true : false
  end

  def self.update_email(user, updated_email)
    user.update(current_email: updated_email)
  end

  def self.accept_eula(user)
    user.update(eula_accepted: true)
  end

  private
    def self.get_compressed_url(video)
      @asset = S3_REQUESTS_COMPRESSED.object("transcoded/#{video}.mp4")
    end

    def self.get_thumbnail_url(video)
      @asset = S3_REQUESTS_THUMBNAILS.object("transcoded/#{video}-00001.png")
    end

end
