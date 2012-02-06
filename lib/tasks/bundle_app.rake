
desc "Bundle application to S3"
task :bundle_app => :environment do
  puts "Bundling application to S3"
  `git archive -o marv.tar HEAD`
  `gzip marv.tar`
  
  require 'rubygems'
  require 'aws/s3'
  AWS::S3::Base.establish_connection!(
    :access_key_id     => '***REMOVED***',
    :secret_access_key => '***REMOVED***'
  )
  
  # upload the new one
  print "Uploading new one..."
  AWS::S3::S3Object.store('marv_new.tar.gz', open('marv.tar.gz'), '***REMOVED***')
  print "done\n"
  
  # rename the old file
  puts "Renaming old code bundle"
  AWS::S3::S3Object.rename "marv.tar.gz", "marv-#{Time.now.strftime('%H%M-%d%m%y')}.tar.gz", "***REMOVED***"
  
  # rename the new file
  AWS::S3::S3Object.rename "marv_new.tar.gz", "marv.tar.gz", "***REMOVED***"
  
  puts "Cleaning up"
  `rm marv.tar.gz`
  puts "Done"
end