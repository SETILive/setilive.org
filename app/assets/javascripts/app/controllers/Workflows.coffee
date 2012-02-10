
class Workflows extends Spine.Controller
  elements: 
    ".answer_list": "answer_list"
    ".question" : "question"
  events:
    "click .answer" : 'selectAnswer'
    
  constructor: ->
    super
    Spine.bind("startWorkflow", @startWorkflow)
    @render()
    @el.hide()
  render:=>
    @html @view('workflow')
      question : @current_question
      helpers : @helpers

  startWorkflow:(signal)=>
    x = @el.parent().width()*(Math.max(signal.freqEnd, signal.freqStart) ) + 20
    y = @el.parent().height()*(signal.timeEnd + signal.timeStart)/2.0 - @el.height()/2.0
    @el.css
      top: y
      left : x
    @el.show()
    @currentSignal = signal
    @setUpQuestion(Workflow.first().questions[0]._id)

  setUpQuestion: (question_id=-1) ->
    workflow = Workflow.first()
    question_id = workflow.questions[0]._id if question_id==-1
     
    for question in workflow.questions
      @current_question= question if question._id==question_id    
    
    @render()
    
  selectAnswer: (event)=>
    console.log("selected answer")
    answer= $(event.currentTarget).data()

   

    @currentSignal.characterisations.push 
      question_id: @current_question._id
      answer_id : answer.id

    if answer.leads_to
      @setUpQuestion(answer.leads_to)
    else
      @doneWorkflow()
    
    Spine.trigger("updateSignal", @currentSignal)
      
  doneWorkflow:->
    @answer_list.html("")
    @el.hide()
    Workflow.trigger 'workflowDone','done'
  
  helpers:
    answer_icon:(answer)->
      lookup=
        "red"      : "<div class='answer-icon' style='display:inline-block; width:10px; height:10px; background-color: red'></div>"
        "white"    : "<div class='answer-icon' style='display:inline-block; width:10px; height:10px; background-color:white'></div>"
        "blue"     : "<div class= 'answer-icon' style='display:inline-block; width:10px; height:10px; background-color:blue'></div>"
        "green"    : "<div class= 'answer-icon' style='display:inline-block; width:10px; height:10px; background-color:green'></div>"
        "spiral"   : "<img src='images/spiral.png' class ='answer-icon' style='display: inline-block'></img>"
        "diagonal" : "<img src='images/diagonal.png' class ='answer-icon' style='display: inline-block'></img>"
        "broken"   : "<img src='images/broken.png' class ='answer-icon' style='display: inline-block'></img>"
        "straight" : "<img src='images/straight.png' class ='answer-icon' style='display: inline-block'></img>"
      lookup[answer.name.toLowerCase()]
    
window.Workflows = Workflows