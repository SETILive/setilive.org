
desc "Bundle application to S3"
task :bundle_app => :environment do
  puts "Bundling application to S3"
  `git archive -o marv.tar HEAD`
  `gzip marv.tar`
  
  require 'rubygems'
  require 'aws-sdk'
  
  AWS.config :access_key_id=>'***REMOVED***', :secret_access_key => '***REMOVED***'

  # upload the new one

  s3 = AWS::S3.new
  bucket = s3.buckets['***REMOVED***']
  object = bucket.objects['marv.tar.gz']
  object_persits = bucket.objects["marv-#{Time.now.strftime('%H%M-%d%m%y')}.tar.gz"]

  data = File.read('marv.tar.gz')
  
  print "Uploading new one..."

  object.write(data)
  print "done\n"


  print "Uploading archive one..."

  object_persits.write(data)
  print "done\n"
  
  # clean up
  
  puts "Cleaning up"
  `rm marv.tar.gz`
  puts "Done"
end