class ThankYou < ApplicationRecord

  validates_presence_of :creator, :pizzas, :vendor

  belongs_to :creator, class_name: "User", foreign_key: :creator_id
  belongs_to :request, class_name: "Request", foreign_key: :request_id

  def self.activity
    ThankYou.where(transcoded: true).map { |thank_you|
      seconds = (Time.now() - thank_you.created_at).round
      {
        id: thank_you.id,
        type: "thankYou",
        creatorId: thank_you.creator_id,
        donorId: thank_you.donor_id,
        requestId: thank_you.request_id,
        pizzas: thank_you.pizzas,
        vendor: thank_you.vendor,
        compressedVideo: get_compressed_url(thank_you.video),
        thumbnail: get_thumbnail_url(thank_you.video),
        seconds: seconds,
        reports: thank_you.reports,
        donorViewed: thank_you.donor_viewed,
        createdAt: thank_you.created_at,
        updatedAt: thank_you.updated_at
      }
    }
  end

  def self.user_history(user_id)
    ThankYou.where(transcoded: true, creator_id: user_id).or(ThankYou.where(transcoded: true, donor_id: user_id)).map { |thank_you|
      seconds = (Time.now() - thank_you.created_at).round
      {
        id: thank_you.id,
        type: "thankYou",
        creatorId: thank_you.creator_id,
        donorId: thank_you.donor_id,
        requestId: thank_you.request_id,
        pizzas: thank_you.pizzas,
        vendor: thank_you.vendor,
        compressedVideo: get_compressed_url(thank_you.video),
        thumbnail: get_thumbnail_url(thank_you.video),
        seconds: seconds,
        reports: thank_you.reports,
        donorViewed: thank_you.donor_viewed,
        createdAt: thank_you.created_at,
        updatedAt: thank_you.updated_at
      }
    }
  end

  def self.anon_history(anon_id)
    ThankYou.where(transcoded: true, creator_id: anon_id).or(ThankYou.where(transcoded: true, donor_id: anon_id)).map { |thank_you|
      seconds = (Time.now() - thank_you.created_at).round
      {
        id: thank_you.id,
        type: "thankYou",
        creatorId: thank_you.creator_id,
        donorId: thank_you.donor_id,
        requestId: thank_you.request_id,
        pizzas: thank_you.pizzas,
        vendor: thank_you.vendor,
        compressedVideo: get_compressed_url(thank_you.video),
        thumbnail: get_thumbnail_url(thank_you.video),
        seconds: seconds,
        reports: thank_you.reports,
        donorViewed: thank_you.donor_viewed,
        createdAt: thank_you.created_at,
        updatedAt: thank_you.updated_at
      }
    }
  end

  def self.transcode(thank_you)
    thank_you.update(transcoded: true)
  end

  def self.report(thank_you)
    thank_you.increment(:reports)
    thank_you.save
  end

  def self.remove(thank_you)
    if thank_you.reports > 3
      thank_you.update(removed: false)
    end
  end

  def self.view(thank_you)
    thank_you.update(donor_viewed: true)
  end

  def self.update_video_key(thank_you, video_key)
    new_video_key = params[:videoKey] + "-" + thank_you.id.to_s
    thank_you.update(video: new_video_key)
  end

  private
    def self.get_compressed_url(video)
      @asset = S3_THANKYOUS_COMPRESSED.object("transcoded/#{video}.mp4")
      @url = @asset.presigned_url(:get)
      # p "@url"
      # p @url
      # p "sub"
      # p @url.sub('in-knead-thankyous-compressed.s3.amazonaws.com', "d2ldogngkzp5pi.cloudfront.net")
      # @url
    end

    def self.get_thumbnail_url(video)
      @asset = S3_THANKYOUS_THUMBNAILS.object("transcoded/#{video}-00001.png")
      @url = @asset.presigned_url(:get)
      # p "@url"
      # p @url
      # p "sub"
      # p @url.sub('in-knead-thankyous-thumbnails.s3.amazonaws.com', "d34vf9lcht8rtn.cloudfront.net")
      # @url
    end
end
