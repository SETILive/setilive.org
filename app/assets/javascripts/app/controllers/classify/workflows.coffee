
class Workflows extends Spine.Controller
  elements: 
    ".answer_list": "answer_list"
    ".question" : "question"
  events:
    "click .answer" : 'selectAnswer'
    "click #delete_signal" : 'deleteSignal'
    
  constructor: ->
    super
    Spine.bind 'startWorkflow', @startWorkflow
    Spine.bind 'closeWorkflow', @closeWorkflow
    @el.hide()
    @render()

  render: =>
    @html @view('workflow')
      question: @current_question
      answerHelper: @answer_icon

  startWorkflow: (signal) =>
    x = @el.parent().width() * (Math.max(signal.freqEnd, signal.freqStart) ) + 20
    y = @el.parent().height() * (signal.timeEnd + signal.timeStart) / 2.0 - @el.height() / 2.0
    @el.css
      top: y
      left: x
    @el.show()

    @currentSignal = signal
    @currentSignal.save()
    @setUpQuestion(Workflow.first().questions[0]._id)

    if @currentSignal.characterisations.length > 0
      @el.find('#close-workflow').show()

  closeWorkflow: =>
    @answer_list.html("")
    @el.hide()

  deleteSignal: (e) =>
    e.stopPropagation()
    @currentSignal.destroy()
    $(".signal_#{@currentSignal.id}").remove()
    @el.hide()
    Workflow.trigger 'workflowDone', 'done'

  setUpQuestion: (question_id = -1) ->
    workflow = Workflow.first()
    question_id = workflow.questions[0]._id if question_id==-1
     
    for question in workflow.questions
      @current_question= question if question._id==question_id    
    
    @render()
    
  selectAnswer: (e) =>
    answer = $(e.currentTarget).data()

    new_characterisation =
      question_id: @current_question._id
      answer_id: answer.id

    index = -1
    
    _.find @currentSignal.characterisations, (characterisation, i) ->
      if characterisation.question_id == new_characterisation.question_id
        index = i
        return true

    if index >= 0
      @currentSignal.characterisations[index] = new_characterisation
    else
      @currentSignal.characterisations.push new_characterisation

    if answer.leads_to
      @setUpQuestion(answer.leads_to)
    else
      @doneWorkflow()
      
  doneWorkflow: =>
    @answer_list.html ''
    @el.hide()
    Workflow.trigger 'workflowDone', 'done'
  
  answer_icon: (answer) ->
    lookup =
      "spiral": "<img src='assets/question_icons/spiral.png' class ='answer-icon' style='display: inline-block'></img>"
      "diagonal": "<img src='assets/question_icons/diagonal.png' class ='answer-icon' style='display: inline-block'></img>"
      "broken": "<img src='assets/question_icons/signal_broken.png' class ='answer-icon' style='display: inline-block'></img>"
      "continuous": "<img src='assets/question_icons/signal_continuous.png' class ='answer-icon' style='display: inline-block'></img>"
      "parallel": "<img src='assets/question_icons/signal_parallel.png' class ='answer-icon' style='display: inline-block'></img>"
      "wide": "<img src='assets/question_icons/signal_broad.png' class ='answer-icon' style='display: inline-block'></img>"
      "narrow": "<img src='assets/question_icons/signal_continuous.png' class ='answer-icon' style='display: inline-block'></img>"  
      "vertical": "<img src='assets/question_icons/straight.png' class ='answer-icon' style='display: inline-block'></img>"
      "erratic": "<img src='assets/question_icons/signal_erratic.png' class ='answer-icon' style='display: inline-block'></img>"
    lookup[answer.name.toLowerCase()]
    
window.Workflows = Workflows