class Request < ApplicationRecord

  validates_presence_of :creator, :pizzas, :vendor

  belongs_to :creator, class_name: "User", foreign_key: :creator_id
  has_one :thank_you, class_name: "ThankYou", foreign_key: :request_id

  def self.activity
    Request.where(removed: false, transcoded: true).where.not(status: "deleted").map { |request|
      seconds = (Time.now() - request.created_at).round
      {
        id: request.id,
        type: "request",
        creatorId: request.creator_id,
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

  def self.user_history(user_id)
    Request.where(creator_id: user_id, removed: false, transcoded: true).where.not(status: "deleted").or(Request.where(donor_id: user_id, removed: false, transcoded: true).where.not(status: "deleted")).map { |request|
      seconds = (Time.now() - request.created_at).round
      {
        id: request.id,
        type: "request",
        creatorId: request.creator_id,
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

  def self.anon_history(anon_id)
    Request.where(creator_id: anon_id, removed: false, transcoded: true).where.not(status: "deleted").or(Request.where(donor_id: anon_id, removed: false, transcoded: true).where.not(status: "deleted")).map { |request|
      seconds = (Time.now() - request.created_at).round
      {
        id: request.id,
        type: "request",
        creatorId: request.creator_id,
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

  def self.show(request)
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
  end

  def self.total_donated_pizzas
    Request.where.not(donor_id: nil).where(status: "received").map{ |request| request.pizzas}.reduce(:+)
  end

  def self.donor_fraud(user_id)
    Request.where(donor_id: user_id, status: "active").count > 1 ? true : false
  end

  def self.expire(user_id)
    Request.where(creator_id: user_id, status: "active").map{ |request|
      request.status = "expired"
      request.save
    }
  end

  def self.transcode(request)
    request.update(transcoded: true)
  end

  def self.report(request)
    request.increment(:reports)
    request.save
  end

  def self.remove(request)
    if request.reports > 3
      request.update(removed: true)
    end
  end

  def self.update_video_key(request, video_key)
    new_video_key = video_key + "-" + request.id.to_s
    request.update(video: new_video_key)
  end

  def self.recent_upload(user_id)
    Request.where(creator: user_id, transcoded: false).where("created_at > ?", DateTime.now - 3.minutes)[0]
  end

  def self.failed_upload(user_id)
    requests = Request.where(creator: user_id, transcoded: false).where("created_at < ?", DateTime.now - 3.minutes)
    if requests[0]
      requests.map { |request|
        request.update(status: "deleted")
      }
    end
  end

  def self.received_donation(request)
    request.update(status: "received")
  end

  def self.donate(request, user_id)
    request.update(donor_id: user_id)
  end

  def self.delete(request)
    request.update(status: "deleted")
  end

  def self.new_removal(user_id)
    Request.where(creator: user_id, removed: true, removal_viewed: false)
  end

  def self.removal_viewed(request)
    request.update(removal_viewed: true)
  end

  private
    def self.get_compressed_url(video)
      @url = "https://s3.amazonaws.com/in-knead-requests-compressed/transcoded/#{video}.mp4"
    end

    def self.get_thumbnail_url(video)
      @url = "https://s3.amazonaws.com/in-knead-requests-thumbnails/transcoded/#{video}-00001.png"
    end
end
