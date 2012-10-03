
class Metric extends Spine.Model
  @configure 'Metric', 'name', 'value'
  @extend Spine.Events

  @fetch: (onSuccess) ->
    $.getJSON '/stats.json', (data) =>
      keys = _.keys data

      for key in keys
        existing_metric = Metric.findByAttribute 'name', key
        metric =
          name: key
          value: data[key]
        unless existing_metric
          Metric.create metric
        else
          @update existing_metric.id, metric

      onSuccess()

window.Metric = Metric