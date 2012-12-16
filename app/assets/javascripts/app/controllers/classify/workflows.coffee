
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
    previous_answer = false

    if @currentSignal
      previous_answer = _.find @currentSignal.characterisations, (characterisation, i) =>
        characterisation.question_id == @current_question._id

    @el.find('#workflow-area').html @view('workflow')
      question: @current_question
      answerHelper: @answer_icon
      previous_answer: previous_answer

  startWorkflow: (signal) =>
    # Adjust workflow position and look
    x = @el.parent().width() * (Math.max(signal.freqEnd, signal.freqStart) ) + 20
    y = @el.parent().height() * (signal.timeEnd + signal.timeStart) / 2.0 - @el.height() / 2.0
    
    # Keep out of thumbnail area where list item clicks aren't recognized
    y = Math.min( y, @el.parent().height() - @el.height() - 10 )
    
    @el.css
      top: y
      left: x

    # Only show 'Close X' if working on an already classified signal
    if signal.characterisations.length > 1
      @el.find('#close-workflow').show()
    else
      @el.find('#close-workflow').hide()

    @el.show()

    # Setup working signal as the current signal
    @currentSignal = signal
    @currentSignal.save()
    @setUpQuestion(Workflow.first().questions[0]._id)

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
    question_id = workflow.questions[0]._id if question_id == -1
     
    for question in workflow.questions
      @current_question = question if question._id == question_id    
    
    @render()
    
  selectAnswer: (e) =>
    e.stopPropagation()
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