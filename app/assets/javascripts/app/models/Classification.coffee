
class Classification extends Spine.Model
  @configure 'Classification', 'subject_id', 'user_id', 'start_time', 'end_time'  
  @hasMany 'signals', 'Signal'

  # constructor : ->
  #   super 
  #   this.start_time = new Date()
    
  newSignal: (x,y,id)=>
    @currentSignal  = @signals().create({timeStart: y, freqStart : x, observation_id: id})

  persist:=>
    console.log("persisiting")
    
    @signals= @signals().all()
  

    $.ajax
      type: 'POST'
      url: '/classifications/'
      data: @toJSON
      dataType: 'json'
      success: (response)->
        window.location='/classify'

  updateSignal:(x,y) =>
    @currentSignal.timeEnd= y
    @currentSignal.freqEnd= x
    @currentSignal.save()



window.Classification = Classification
