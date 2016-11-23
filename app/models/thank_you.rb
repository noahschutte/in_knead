class ThankYou < ApplicationRecord

  validates_presence_of :creator, :pizzas, :vendor, :video

  belongs_to :creator, class_name: "User", foreign_key: :creator_id
  belongs_to :request, class_name: "Request", foreign_key: :request_id

  def self.activity
    ThankYou.order('created_at DESC').map { |thank_you|
      seconds = (Time.now() - thank_you.created_at).round
      {
        id: thank_you.id,
        type: "thankYou",
        creator_id: thank_you.creator_id,
        pizzas: thank_you.pizzas,
        vendor: thank_you.vendor,
        video: get_url(thank_you.video),
        seconds: seconds,
        reports: thank_you.reports,
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
        pizzas: thank_you.pizzas,
        vendor: thank_you.vendor,
        video: get_url(thank_you.video),
        seconds: seconds,
        reports: thank_you.reports,
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
        pizzas: thank_you.pizzas,
        vendor: thank_you.vendor,
        video: get_url(thank_you.video),
        seconds: seconds,
        reports: thank_you.reports,
        created_at: thank_you.created_at,
        updated_at: thank_you.updated_at
      }
    }
  end

  private
    def self.get_url(video)
      @asset = S3_BUCKET.object("uploads/#{video}")
      @url = @asset.presigned_url(:get)
    end
end
