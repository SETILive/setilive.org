
class Workflows extends Spine.Controller
  elements: 
    ".answer_list": "answer_list"
    ".question" : "question"
  events:
    "click .answer" : 'selectAnswer'
    
  constructor: ->
    super
    Spine.bind("startWorkflow", @startWorkflow)
    @el.hide()
    Workflow.fetch()
  
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
    @question.html @view("workflow_question")(@current_question)
    @answer_list.html("")    
    answers  = @current_question.answers
    

    answer.icon = @helpers.answer_icon(answer.name) for answer in answers
    @answer_list.append @view('workflow_answers')(answers)
  
  selectAnswer: (event)=>
    answer= $(event.target).data('item')
    @currentSignal.characterisations.push 
      question_id: @current_question._id
      answer_id : answer._id

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
      lookup[answer.toLowerCase()]
    
window.Workflows = Workflows