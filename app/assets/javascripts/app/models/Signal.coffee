
class Signal extends Spine.Model
  @configure 'Signal', 'freqStart', 'freqEnd','timeStart', 'timeEnd', 'characterisations'
  @belongsTo "classification", "models/Classification"
  

  # @url : =>
    # "/classifications/#{@classification.id}/signal/"

  constructor : ->
    super 
    @characterisations=[]

  gradient : ->
    (@timeEnd - @timeStart)/(@freqEnd - @freqStart)

  color : ->
    lookup =
        "4ecbcc1f40af4716ef000002":"white" 
        "4ecbcc1f40af4716ef000003":"red"
        "4ecbcc1f40af4716ef000004":"blue"
        "4ecbcc1f40af4716ef000005":"green"

    for pair in @characterisations
      if pair.question_id =='4ecbcc1f40af4716ef000001' 
        return lookup[pair.answer_id]
  
  signalType : ->
    lookup =
      "4ecbcc1f40af4716ef000007":"straight" 
      "4ecbcc1f40af4716ef000008":"spiral"
      "4ecbcc1f40af4716ef000009":"diagional"
      "4ecbcc1f40af4716ef000010":"broken"

    for pair in @characterisations
      if pair.question_id =='4ecbcc1f40af4716ef000006' 
        return lookup[pair.answer_id]


  interp: (x) ->
    (x-@freqStart)*@gradient() + @timeStart

window.Signal = Signal
