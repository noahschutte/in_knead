class ThankYou < ApplicationRecord

  validates_presence_of :creator, :pizzas, :vendor

  belongs_to :creator, class_name: "User", foreign_key: :creator_id
  belongs_to :request, class_name: "Request", foreign_key: :request_id

  def self.activity
    ThankYou.where(removed: false, transcoded: true).where.not(status: "deleted").map { |thank_you|
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
    ThankYou.where(creator_id: user_id, removed: false, transcoded: true).where.not(status: "deleted").or(ThankYou.where(donor_id: user_id, removed: false, transcoded: true).where.not(status: "deleted")).map { |thank_you|
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
    ThankYou.where(creator_id: anon_id, removed: false, transcoded: true).where.not(status: "deleted").or(ThankYou.where(donor_id: anon_id, removed: false, transcoded: true).where.not(status: "deleted")).map { |thank_you|
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

  def self.received_thank_yous(user_id)
    ThankYou.where(donor_id: user_id, donor_viewed: false, transcoded: true, removed: false).where.not(status: "deleted").map { |thank_you|
      seconds = (Time.now() - thank_you.created_at).round
      {
        id: thank_you.id,
        type: "thankYou",
        seconds: seconds,
        requestId: thank_you.request_id,
        creatorId: thank_you.creator_id,
        pizzas: thank_you.pizzas,
        vendor: thank_you.vendor,
        compressedVideo: get_compressed_url(thank_you.video),
        thumbnail: get_thumbnail_url(thank_you.video),
        donorId: thank_you.donor_id,
        reports: thank_you.reports,
        donorViewed: thank_you.donor_viewed,
        status: thank_you.status,
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
      thank_you.update(removed: true)
    end
  end

  def self.view(thank_you)
    thank_you.update(donor_viewed: true)
  end

  def self.update_video_key(thank_you, video_key)
    new_video_key = video_key + "-" + thank_you.id.to_s
    thank_you.update(video: new_video_key)
  end

  # Change ThankYou.viewed to true on creation if the donor has blocked the ThankYou creator
  def self.donor_blocked(thank_you)
    User.find(thank_you.donor_id).blocked.map { |blocked_user|
      if blocked_user == thank_you.creator_id
        thank_you.update(donor_viewed: true)
      end
    }
  end

  def self.failed_upload(user_id)
    thank_yous = ThankYou.where(creator: user_id, transcoded: false).where("created_at < ?", DateTime.now - 3.minutes)
    if thank_yous[0]
      thank_yous.map { |thank_you|
        thank_you.update(status: "deleted")
      }
    end
  end

  def self.delete(thank_you)
    @thank_you.update(status: "deleted")
  end

  def self.new_removal(user_id)
    ThankYou.where(creator: user_id, removed: true, removal_viewed: false)
  end

  def self.removal_viewed(thank_you)
    thank_you.update(removal_viewed: true)
  end

  private
    def self.get_compressed_url(video)
      @url = "https://#{ENV['CF_THANKYOUS_COMPRESSED']}/transcoded/#{video}.mp4"
    end

    def self.get_thumbnail_url(video)
      @url = "https://#{ENV['CF_THANKYOUS_THUMBNAILS']}/transcoded/#{video}-00001.png"
    end
end
