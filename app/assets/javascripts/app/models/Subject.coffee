
class Subject extends Spine.Model
  @configure 'Subject','observations','activityId', 'bandwidthMhz', 'bitPix', 'centerFreqMhz', 'endTimeNanos', 'uploaded', 'image_url', 'thumb_url','data_url'
  @extend Spine.Events

  
  @fetch_from_url: (url) ->
    $.getJSON url, (data)->
      subject=  Subject.create(data)
      unless subject.uploaded
       @trigger('got')
    
  @fetch_next_for_user: ->
    $.getJSON "next_subject.json", (data)->
      subject=  Subject.create(data)
      Subject.trigger('next_subject', subject)
  
  @get_tutorial_subject: ->
    $.getJSON "tutorial_subject.json", (data)->
      subject=  Subject.create(data)
      Subject.trigger('next_subject', subject)
    
  imageDataForBeam:(beamNo,targetWidth,targetHeight)->
    imageData=[]
    imageData[i] =0 for i in [0..targetWidth*targetHeight]
    data = @observations[beamNo].data
    bounds = @calcBounds()
    width = @observations[beamNo].width
    height = @observations[beamNo].height
    for x in [0..targetWidth]
      for y in [0..targetHeight]
        imagePos = (y+x*targetWidth)*4
        dataPosX = Math.floor((x*1.0)*width/(targetWidth*1.0))
        dataPosY = Math.floor((y*1.0)*height/(targetHeight*1.0))

        dataVal = 0
        for bx in [0..0]
          for bY in [0..0]
            dataPos  = ( (dataPosX+ bx) + (dataPosY+bY)*width)
            dataVal += data[dataPos] 
        
        
        dataVal=@scaleVal dataVal, beamNo
        

        Subject.setPixel(imageData,targetWidth,x,y, dataVal,dataVal,dataVal,255)
    
    imageData
    
  imageDataForCombinedBeam:(targetWidth,targetHeight)->
    imageData=[]
    
    for i in [0..targetWidth*targetHeight]
      imageData.push(0)  
  
    for x in [0..targetWidth]
      for y in [0..targetHeight]
        imagePos = (y+x*targetWidth)*4
        dataPosX = Math.floor((x*1.0)*@width/(targetWidth*1.0))
        dataPosY = Math.floor((y*1.0)*@height/(targetHeight*1.0))

        dataR = 0
        dataG = 0
        dataB = 0

        for bx in [-1..1]
          for bY in [-1..1]
            dataPos  = ( (dataPosX+ bx) + (dataPosY+bY)*@width)
            dataR    += @beam1[dataPos] /1.5
            dataG    += @beam2[dataPos] /1.5
            dataB    += @beam3[dataPos] /1.5
      
        dataR=@scaleVal dataR, 1
        dataG=@scaleVal dataG, 2
        dataB=@scaleVal dataB, 3      

        Subject.setPixel(imageData,targetWidth,x,y, dataR, dataG, dataB,255)
    imageData

        

  calcBounds : ->
    unless @bounds?
      @bounds = []
      for beam, beamNo in @observations
        max = 0
        min = 100000000
        for val in beam.data
          max = val if val > max
          min = val if val < min
        @bounds[beamNo] = [min- (max-min)*0.0,max]
    @bounds 

  scaleVal :(val,beamNo)->
    bounds = @calcBounds()
    (val-bounds[beamNo][0])*255/(bounds[beamNo][1]-bounds[beamNo][0])

  talkURL :->
    "http://talk.setilive.org/observation_groups/#{@zooniverse_id}"

  @setPixel:(imageData, width,x, y, r, g, b, a) ->
    index = (x + y * width) * 4;
    
    imageData[index+0] = r;
    imageData[index+1] = g;
    imageData[index+2] = b;
    imageData[index+3] = a;

window.Subject = Subject