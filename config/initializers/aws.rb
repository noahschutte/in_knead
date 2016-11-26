Aws.config.update({
  region: ENV['AWS_REGION'],
  credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
})

S3_BUCKET = Aws::S3::Resource.new.bucket(ENV['S3_BUCKET'])

S3_COMPRESSED_BUCKET = Aws::S3::Resource.new.bucket(ENV['S3_COMPRESSED_BUCKET'])

S3_THUMBNAIL_BUCKET = Aws::S3::Resource.new.bucket(ENV['S3_THUMBNAIL_BUCKET'])
