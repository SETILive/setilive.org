class Workflows extends Spine.Controller
  elements: 
    ".answer_list": "answer_list"
    ".question" : "question"
  events:
    "click .answer" : 'selectAnswer'
    "click #delete_signal" : 'deleteSignal'
    
  constructor: ->
    super
    Spine.bind("startWorkflow", @startWorkflow)
    @render()
    @el.hide()

  render:=>
    @html @view('workflow')
      question : @current_question
      answerHelper : @answer_icon

  startWorkflow:(signal)=>
    x = @el.parent().width()*(Math.max(signal.freqEnd, signal.freqStart) ) + 20
    y = @el.parent().height()*(signal.timeEnd + signal.timeStart)/2.0 - @el.height()/2.0
    @el.css
      top: y
      left : x
    @el.show()
    @currentSignal = signal
    @currentSignal.characterisations =[]
    @currentSignal.save()
    @setUpQuestion(Workflow.first().questions[0]._id)


  deleteSignal:(e)=>
    e.stopPropagation()
    @currentSignal.destroy()
    $(".signal_#{@currentSignal.id}").remove()
    @el.hide()
    Workflow.trigger 'workflowDone','done'


  setUpQuestion: (question_id=-1) ->
    workflow = Workflow.first()
    question_id = workflow.questions[0]._id if question_id==-1
     
    for question in workflow.questions
      @current_question= question if question._id==question_id    
    
    @render()
    
  selectAnswer: (event)=>
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
  
  answer_icon:(answer)->
    lookup=
      "spiral"   : "<img src='assets/question_icons/spiral.png' class ='answer-icon' style='display: inline-block'></img>"
      "diagonal" : "<img src='assets/question_icons/diagonal.png' class ='answer-icon' style='display: inline-block'></img>"
      "broken"   : "<img src='assets/question_icons/signal_broken.png' class ='answer-icon' style='display: inline-block'></img>"
      "continuous"   : "<img src='assets/question_icons/signal_continuous.png' class ='answer-icon' style='display: inline-block'></img>"
      "parallel"   : "<img src='assets/question_icons/signal_parallel.png' class ='answer-icon' style='display: inline-block'></img>"
      "wide"   : "<img src='assets/question_icons/signal_broad.png' class ='answer-icon' style='display: inline-block'></img>"
      "narrow"   : "<img src='assets/question_icons/signal_continuous.png' class ='answer-icon' style='display: inline-block'></img>"  
      "vertical" : "<img src='assets/question_icons/straight.png' class ='answer-icon' style='display: inline-block'></img>"
      "erratic" : "<img src='assets/question_icons/signal_erratic.png' class ='answer-icon' style='display: inline-block'></img>"
    lookup[answer.name.toLowerCase()]
    
window.Workflows = Workflows