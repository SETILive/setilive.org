
class Classification extends Spine.Model
  @configure 'Classification', 'subject_id', 'user_id', 'start_time', 'end_time'  
  @hasMany 'signals', 'Signal'

  # constructor : ->
  #   super 
  #   this.start_time = new Date()
    
  newSignal: (x,y,id)=>
    @currentSignal  = @signals().create({timeStart: y, freqStart : x, observation_id: id})

  persist:=>    
    window.classificaiton=@
    signals = (signal.toJSON() for signal in @signals().all())
    
    result = 
      signals : signals
      subject_id : @subject_id


    $.ajax
      type: 'POST'
      url: '/classifications/'
      data: result
      dataType: 'json'
      success: (response)->
        Spine.trigger("classificationSaved")

  updateSignal:(x,y) =>
    @currentSignal.timeEnd= y
    @currentSignal.freqEnd= x
    @currentSignal.save()

  @fetchRecent:(callback)->
    $.getJSON "/recent_classifications.json", (data)=>
      callback(data)



window.Classification = Classification
