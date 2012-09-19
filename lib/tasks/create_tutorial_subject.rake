task :create_lots_of_subject => :environment do
  Dir.glob("/Users/stuartlynn/Desktop/zoo-test-bson/act7.1.1").each do |file|
    subject = Subject.generate_subject_from_frank(BSON.deserialize(IO.read(file)))
    filename = file.split("/").last
    subject.observations.each_with_index do |obs,index|
      png = ObservationUploader.new.make_png obs, 758, 410
      png.save("#{filename.gsub('.bson',index.to_s)}.png")
    end
  end
end


task :create_tutorial_subject => :environment do
  Subject.delete_all
  signalFile_url = "https://s3.amazonaws.com/zooniverse-seti-dev/tutorial/signal.png"
  noiseFile_url  = "https://s3.amazonaws.com/zooniverse-seti-dev/tutorial/noise.png"

    
  s = Subject.create(:activity_id=>'tutorial',:freq_range=>"533.3330078125", :location => {:time => "1329147983500000000",:freq => "2956.66430664062"})
  s.observations.create(:source => Source.first, :thumb_url=>signalFile_url, :image_url=>signalFile_url, :beam_no=>1, :width=>768, :height=>129, :uploaded=>true,:type=>"tutorial")
  s.observations.create(:source => Source.first(:skip=>1), :thumb_url=>noiseFile_url, :image_url=>noiseFile_url, :beam_no=>2, :width=>768, :height=>129, :uploaded=>true,:type=>"tutorial")

end