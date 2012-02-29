require 'json'


def load_kepler_sources(file)
  keplerSources = IO.read(file).split("\n").collect{|l|l.split(" ")}
  header = keplerSources[0]
  data = keplerSources[2..-1]
  result = {}
  data.each do |kepler_planet|
    details ={}
    kepler_planet.each_with_index do |detail,index|
      details[header[index]]= detail
    end
    result[kepler_planet[1]]= details
  end
  result
end

planetData= load_kepler_sources("newKeplerIdList.txt")
targets =    IO.read("keplerlist.txt").split("\n").collect{|l| l.split(" ")}
starData   = IO.read("starinfo.csv").split("\n")[1..-1].inject({}){|h,l| l=l.split(","); h[l[2].gsub("\"","")]= l ; h}

newList = {}
misses  = []

targets.each do |target|
  seti_id = target[0]
  koi = target[2].split(",")[0].strip

  pdata  = planetData[koi]
 

  if pdata
    puts pdata
    kepler_id = pdata['Kepler_ID']
    kepler_id = "kplr%9.9i"%kepler_id
    starInfo  = starData[kepler_id]
    
    if starInfo
      planetInfo = planetData[koi]
      newList [kepler_id] ||= {}
      newList [kepler_id]['star_info'] = {:ra => starInfo[0].to_f, :dec=>starInfo[1].to_f, :star_type =>starInfo[3].gsub("\"","") , :spec_type=> starInfo[4].gsub("\"",""), :eff_temp=>starInfo[5].to_f, :log_g=>starInfo[6].to_f, :stellar_rad =>starInfo[7].to_f, :kepler_mag => starInfo[8].to_f, :zooniverse_id =>starInfo[12].gsub("\"","")}

      newList[kepler_id]['planets'] ||=[]
      newList[kepler_id]['seti_ids'] ||=[]
      newList[kepler_id]['seti_ids']<< seti_id

      puts planetInfo
      puts starInfo

      newList[kepler_id]['planets'] << {:koi=>koi,:seti_id=>seti_id, :duration=>planetInfo["Dur(h)"].to_f, :depth=>planetInfo["Depth(ppm)"].to_f, :t0=>planetInfo["t0(day)"].to_f, :period => planetInfo["Period(days)"].to_f, :radius => planetInfo["p_Rad(Earth)"].to_f, :a => planetInfo["a(AU)"].to_f, :Teq=>planetInfo["Teq(K)"].to_f}
    else
      misses<< kepler_id 
    end
  else
    misses<< kepler_id 
  end

end

File.open("setiKeplerTargets.json", "w") {|f| f.puts JSON.pretty_generate newList}
File.open("misses.json","w"){|f| f.puts misses.to_json}

