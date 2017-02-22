class Request < ApplicationRecord

    validates_presence_of :creator, :pizzas, :vendor, :video

    belongs_to :creator, class_name: "User", foreign_key: :creator_id
    has_one :thank_you, class_name: "ThankYou", foreign_key: :request_id

  def self.open_requests
    # Request.where("created_at > ?", DateTime.now - 24.hours).order('created_at DESC')

    Request.where(transcoded: true).order('created_at DESC').map { |request|
      seconds = (Time.now() - request.updated_at).round
      {
        id: request.id,
        type: "request",
        creator_id: request.creator_id,
        pizzas: request.pizzas,
        vendor: request.vendor,
        compressed_video: get_compressed_url(request.video),
        thumbnail: get_thumbnail_url(request.video),
        donor_id: request.donor_id,
        seconds: seconds,
        status: request.status,
        reports: request.reports,
        created_at: request.created_at,
        updated_at: request.updated_at
      }
    }
  end

  def self.user_history(user_id)
    Request.where(creator_id: user_id).or(Request.where(donor_id: user_id)).order('updated_at DESC').map { |request|
      seconds = (Time.now() - request.updated_at).round
      {
        id: request.id,
        type: "request",
        creator_id: request.creator_id,
        pizzas: request.pizzas,
        vendor: request.vendor,
        compressed_video: get_compressed_url(request.video),
        thumbnail: get_thumbnail_url(request.video),
        donor_id: request.donor_id,
        seconds: seconds,
        status: request.status,
        reports: request.reports,
        created_at: request.created_at,
        updated_at: request.updated_at
      }
    }
  end

  def self.anon_history(anon_id)
    Request.where(creator_id: anon_id).or(Request.where(donor_id: anon_id)).order('updated_at DESC').map { |request|
      seconds = (Time.now() - request.updated_at).round
      {
        id: request.id,
        type: "request",
        creator_id: request.creator_id,
        pizzas: request.pizzas,
        vendor: request.vendor,
        compressed_video: get_compressed_url(request.video),
        thumbnail: get_thumbnail_url(request.video),
        donor_id: request.donor_id,
        seconds: seconds,
        status: request.status,
        reports: request.reports,
        created_at: request.created_at,
        updated_at: request.updated_at
      }
    }
  end

  def self.show(id)
    @request = Request.find(id)
    @seconds = (Time.now() - @request.updated_at).round
    {
      id: @request.id,
      type: "request",
      creator_id: @request.creator_id,
      pizzas: @request.pizzas,
      vendor: @request.vendor,
      compressed_video: get_compressed_url(@request.video),
      thumbnail: get_thumbnail_url(@request.video),
      donor_id: @request.donor_id,
      seconds: @seconds,
      status: @request.status,
      reports: @request.reports,
      created_at: @request.created_at,
      updated_at: @request.updated_at
    }
  end

  def self.total_pizzas_donated
    Request.where.not(donor_id: nil).map{|request| request.pizzas}.reduce(:+)
  end

  def self.active_donation(user)
    Request.where(donor_id: user.id).where("updated_at > ?", DateTime.now - 30.minutes)[0]
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
    # def self.get_url(video)
    #   @asset = S3_REQUESTS.object("#{video}")
    #   @url = @asset.presigned_url(:get)
      # @url.sub('in-knead.s3.amazonaws.com', "d32riymt5m6pak.cloudfront.net")
    # end

    def self.get_compressed_url(video)
      @asset = S3_REQUESTS_COMPRESSED.object("transcoded/#{video}.mp4")
      @url = @asset.presigned_url(:get)
      p "@url"
      p @url
      p "sub"
      p @url.sub('in-knead-requests-compressed.s3.amazonaws.com', "d11afr9krw05ex.cloudfront.net")
      @url
    end

    def self.get_thumbnail_url(video)
      @asset = S3_REQUESTS_THUMBNAILS.object("transcoded/#{video}-00001.png")
      @url = @asset.presigned_url(:get)
      p "@url"
      p @url
      p "sub"
      p @url.sub('in-knead-requests-thumbnails.s3.amazonaws.com', "d2ed940i9bzi4l.cloudfront.net")
      @url
    end
end
