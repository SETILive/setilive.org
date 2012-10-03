
class Metrics extends Spine.Controller

  constructor: ->
    super
    if Metric.count() == 0
      Metric.fetch @render
    else
      @render()

  render: =>
    people_online =
      name: 'People Classifying'
      value: Metric.findByAttribute('name', 'people_online').value

    total_classifications =
      name: 'Total Classifications'
      value: Metric.findByAttribute('name', 'total_classifications').value

    total_users =
      name: 'Total People'
      value: Metric.findByAttribute('name', 'total_users').value

    classification_rate =
      name: 'Classification Rate'
      value: Metric.findByAttribute('name', 'classification_rate').value

    @el.html @view('global_stats')({
        people_online: people_online
        total_classifications: total_classifications
        total_users: total_users
        classification_rate: classification_rate
      })

window.Metrics = Metrics