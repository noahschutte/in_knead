class Request < ApplicationRecord

    validates_presence_of :creator, :pizzas, :vendor, :video
    belongs_to :creator, class_name: "User", foreign_key: :creator_id

  def self.open_requests
    # Request.where("created_at > ?", DateTime.now - 24.hours).order('created_at DESC')

    Request.order('created_at DESC').map { |request|
      minutes = ((Time.now() - request.created_at) / 60).round
      {
        id: request.id,
        creator_id: request.creator_id,
        pizzas: request.pizzas,
        vendor: request.vendor,
        video: get_url(request.video),
        donor_id: request.donor_id,
        minutes: minutes
      }
    }
  end

  def self.user_history(user_id)
    Request.where(creator_id: user_id).or(Request.where(donor_id: user_id)).order('updated_at DESC').map { |request|
      minutes = ((Time.now() - request.created_at) / 60).round
      {
        id: request.id,
        creator_id: request.creator_id,
        pizzas: request.pizzas,
        vendor: request.vendor,
        video: get_url(request.video),
        donor_id: request.donor_id,
        minutes: minutes
      }
    }
  end

  def self.anon_history(anon_id)
    Request.where(creator_id: anon_id).or(Request.where(donor_id: anon_id)).order('updated_at DESC').map { |request|
      minutes = ((Time.now() - request.created_at) / 60).round
      {
        id: request.id,
        creator_id: request.creator_id,
        pizzas: request.pizzas,
        vendor: request.vendor,
        video: get_url(request.video),
        donor_id: request.donor_id,
        minutes: minutes
      }
    }
  end

  def self.total_pizzas_donated
    Request.where.not(donor_id: nil).map{|request| request.pizzas}.reduce(:+)
  end

  def self.active_donation(user)
    Request.where(donor_id: user.id).where("updated_at > ?", DateTime.now - 30.minutes)[0]
  end

  def self.get_url(video)
    @asset = S3_BUCKET.object("uploads/#{video}")
    @url = @asset.presigned_url(:get)
  end
end
