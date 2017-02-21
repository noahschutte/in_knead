class ThankYou < ApplicationRecord

  validates_presence_of :creator, :pizzas, :vendor, :video

  belongs_to :creator, class_name: "User", foreign_key: :creator_id
  belongs_to :request, class_name: "Request", foreign_key: :request_id

  def self.activity
    ThankYou.where(transcoded: true).order('created_at DESC').map { |thank_you|
      seconds = (Time.now() - thank_you.created_at).round
      {
        id: thank_you.id,
        type: "thankYou",
        creator_id: thank_you.creator_id,
        donor_id: thank_you.donor_id,
        pizzas: thank_you.pizzas,
        vendor: thank_you.vendor,
        compressed_video: get_compressed_url(thank_you.video),
        thumbnail: get_thumbnail_url(thank_you.video),
        seconds: seconds,
        reports: thank_you.reports,
        donor_viewed: thank_you.donor_viewed,
        created_at: thank_you.created_at,
        updated_at: thank_you.updated_at
      }
    }
  end

  def self.user_history(user_id)
    ThankYou.where(creator_id: user_id).order('updated_at DESC').map { |thank_you|
      seconds = (Time.now() - thank_you.created_at).round
      {
        id: thank_you.id,
        type: "thankYou",
        creator_id: thank_you.creator_id,
        donor_id: thank_you.donor_id,
        pizzas: thank_you.pizzas,
        vendor: thank_you.vendor,
        compressed_video: get_compressed_url(thank_you.video),
        thumbnail: get_thumbnail_url(thank_you.video),
        seconds: seconds,
        reports: thank_you.reports,
        donor_viewed: thank_you.donor_viewed,
        created_at: thank_you.created_at,
        updated_at: thank_you.updated_at
      }
    }
  end

  def self.anon_history(anon_id)
    ThankYou.where(creator_id: anon_id).order('updated_at DESC').map { |thank_you|
      seconds = (Time.now() - thank_you.created_at).round
      {
        id: thank_you.id,
        type: "thankYou",
        creator_id: thank_you.creator_id,
        donor_id: thank_you.donor_id,
        pizzas: thank_you.pizzas,
        vendor: thank_you.vendor,
        compressed_video: get_compressed_url(thank_you.video),
        thumbnail: get_thumbnail_url(thank_you.video),
        seconds: seconds,
        reports: thank_you.reports,
        donor_viewed: thank_you.donor_viewed,
        created_at: thank_you.created_at,
        updated_at: thank_you.updated_at
      }
    }
  end

  private
    # def self.get_url(video)
    #   @asset = S3_THANKYOUS.object("#{video}")
    #   @url = @asset.presigned_url(:get)
      # @url.sub('in-knead.s3.amazonaws.com', "d32riymt5m6pak.cloudfront.net")
    # end

    def self.get_compressed_url(video)
      @asset = S3_THANKYOUS_COMPRESSED.object("transcoded/#{video}.mp4")
      @url = @asset.presigned_url(:get)
      p "@url"
      p @url
      p "sub"
      p @url.sub('in-knead-thankyous-compressed.s3.amazonaws.com', "d2ldogngkzp5pi.cloudfront.net")
      @url
    end

    def self.get_thumbnail_url(video)
      @asset = S3_THANKYOUS_THUMBNAILS.object("transcoded/#{video}-00001.png")
      @url = @asset.presigned_url(:get)
      p "@url"
      p @url
      p "sub"
      p @url.sub('in-knead-thankyous-thumbnails.s3.amazonaws.com', "d34vf9lcht8rtn.cloudfront.net")
      @url
    end
end
