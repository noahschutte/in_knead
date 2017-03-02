class Request < ApplicationRecord

    validates_presence_of :creator, :pizzas, :vendor, :video

    belongs_to :creator, class_name: "User", foreign_key: :creator_id
    has_one :thank_you, class_name: "ThankYou", foreign_key: :request_id

  def self.activity
    Request.where(transcoded: true).map { |request|
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
    Request.where(transcoded: true).where(creator_id: user_id).or(Request.where(transcoded: true).where(donor_id: user_id)).map { |request|
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
    Request.where(transcoded: true).where(creator_id: anon_id).or(Request.where(transcoded: true).where(donor_id: anon_id)).map { |request|
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

  def self.show(request_id)
    request = Request.find(request_id)
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
    Request.where(donor_id: user_id).where(status: "active").count > 1 ? true : false
  end

  def self.expire(user_id)
    Request.where(creator_id: user_id).where(status: "active").map{ |request|
      request.status = "expired"
      request.save
    }
  end

  private
    def self.get_compressed_url(video)
      @asset = S3_REQUESTS_COMPRESSED.object("transcoded/#{video}.mp4")
      @url = @asset.presigned_url(:get)
      # p "@url"
      # p @url
      # p "sub"
      # p @url.sub('in-knead-requests-compressed.s3.amazonaws.com', "d11afr9krw05ex.cloudfront.net")
      # @url
    end

    def self.get_thumbnail_url(video)
      @asset = S3_REQUESTS_THUMBNAILS.object("transcoded/#{video}-00001.png")
      @url = @asset.presigned_url(:get)
      # p "@url"
      # p @url
      # p "sub"
      # p @url.sub('in-knead-requests-thumbnails.s3.amazonaws.com', "d2ed940i9bzi4l.cloudfront.net")
      # @url
    end
end
