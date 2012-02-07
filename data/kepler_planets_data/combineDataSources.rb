require 'json'

targetData = JSON.parse(IO.read("setiKeplerTargetsInfo.json"))
starData   = IO.read("starinfo.csv").split("\n")[1..-1].inject({}){|h,l| l=l.split(","); h[l[2].gsub("\"","")]= l ; h}
planetData = IO.read("keplerPlanetCandidates.csv").split("\n")[1..-1].inject({}){|h,l| l=l.split(" "); h["kplr%9.9i_#{l[1]}"%l[0]] = l[1..-1] ; h}

newList = {}
misses  = []

targetData.each do |target|
  kepler_id = "kplr%9.9i"% target['kic']
  kio       = target['KOI']
  starInfo  = starData[kepler_id]

  if starInfo
    planetInfo = planetData["#{kepler_id}_#{kio}"]
    newList [kepler_id] ||= {}
    newList [kepler_id]['star_info'] = {:ra => starInfo[0].to_f, :dec=>starInfo[1].to_f, :star_type =>starInfo[3].gsub("\"","") , :spec_type=> starInfo[4].gsub("\"",""), :eff_temp=>starInfo[5].to_f, :log_g=>starInfo[6].to_f, :stellar_rad =>starInfo[7].to_f, :kepler_mag => starInfo[8].to_f, :zooniverse_id =>starInfo[12].gsub("\"","")}
    newList [kepler_id]['planets'] ||=[]

    newList [kepler_id]['planets'] << {:kio=>kio, :duration=>planetInfo[1].to_f, :depth=>planetInfo[2].to_f, :t0=>planetInfo[4].to_f, :period => planetInfo[6].to_f, :radius => planetInfo[14].to_f, :a => planetInfo[15].to_f, :Teq=>planetInfo[16].to_f}
  else
    misses<< kepler_id 
  end

end

File.open("setiKeplerTargets.json", "w") {|f| f.puts JSON.pretty_generate newList}
File.open("misses.json","w"){|f| f.puts misses.to_json}