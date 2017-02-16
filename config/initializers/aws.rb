Aws.config.update({
  region: ENV['AWS_REGION'],
  credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
})

S3_REQUESTS = Aws::S3::Resource.new.bucket(ENV['S3_REQUESTS'])
S3_REQUESTS_COMPRESSED = Aws::S3::Resource.new.bucket(ENV['S3_REQUESTS_COMPRESSED'])
S3_REQUESTS_THUMBNAILS = Aws::S3::Resource.new.bucket(ENV['S3_REQUESTS_THUMBNAILS'])

S3_THANKYOUS = Aws::S3::Resource.new.bucket(ENV['S3_THANKYOUS'])
S3_THANKYOUS_COMPRESSED = Aws::S3::Resource.new.bucket(ENV['S3_THANKYOUS_COMPRESSED'])
S3_THANKYOUS_THUMBNAILS = Aws::S3::Resource.new.bucket(ENV['S3_THANKYOUS_THUMBNAILS'])
