Onodo.Views.Nodes ||= {}

class Onodo.Views.Nodes.GraphView extends Backbone.View

  el: '.visualization-graph-component'

  initialize: ->
    console.log 'initialize GraphView'
    #@collection.bind('reset', @addAll)
    @collection.once 'sync', @onCollectionSync , @

  onCollectionSync: =>
    console.log 'GraphView.onCollectionSync', @collection
    @collection.bind 'change', @onCollectionChange, @
    @render()
  
  onCollectionChange: (e) =>
    console.log 'Collection has changed', e

  render: =>
    console.log 'render GraphView'
    React.render <VisualizationGraph data={@collection.models}/>, @$el.get(0)
    #React.createElement(VisualizationGraph, {data: @collection.models}, @$el.get(0))
    return this