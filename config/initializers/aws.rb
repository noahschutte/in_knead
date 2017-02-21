Aws.config.update({
  region: ENV['AWS_REGION'],
  credentials: Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
})

# policy = {
#    "Statement":[
#       {
#          "Resource": "https://d2ldogngkzp5pi.cloudfront.net/transcoded/4444.mp4",
#          "Condition":{
#             "DateLessThan":{
#                "AWS:EpochTime": "1557034400"
#             }
#          }
#       }
#    ]
# }
#
# signer = Aws::CloudFront::UrlSigner.new(
#   key_pair_id: ENV['CLOUDFRONT_KEYPAIR_ID'],
#   private_key_path: "pk-APKAIAHZ2UF3MM4TRS6Q.pem"
# )
# url = signer.signed_url(url,
#   policy: policy
# )

S3_REQUESTS = Aws::S3::Resource.new.bucket(ENV['S3_REQUESTS'])
S3_REQUESTS_COMPRESSED = Aws::S3::Resource.new.bucket(ENV['S3_REQUESTS_COMPRESSED'])
S3_REQUESTS_THUMBNAILS = Aws::S3::Resource.new.bucket(ENV['S3_REQUESTS_THUMBNAILS'])

S3_THANKYOUS = Aws::S3::Resource.new.bucket(ENV['S3_THANKYOUS'])
S3_THANKYOUS_COMPRESSED = Aws::S3::Resource.new.bucket(ENV['S3_THANKYOUS_COMPRESSED'])
S3_THANKYOUS_THUMBNAILS = Aws::S3::Resource.new.bucket(ENV['S3_THANKYOUS_THUMBNAILS'])
