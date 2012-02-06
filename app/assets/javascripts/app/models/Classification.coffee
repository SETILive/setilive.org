
class Classification extends Spine.Model
  @configure 'Classification', 'subject_id', 'user_id', 'start_time', 'end_time'  
  @hasMany 'signals', 'models/Signal'
  @extend Spine.Model.Ajax

  constructor : ->
    super 
    this.start_time = new Date()
    
  newSignal: (x,y)=>
    @currentSignal  = @signals().create({timeStart: y, freqStart : x})

  updateSignal:(x,y) =>
    @currentSignal.timeEnd= y
    @currentSignal.freqEnd= x
    @currentSignal.save()



window.Classification = Classification
