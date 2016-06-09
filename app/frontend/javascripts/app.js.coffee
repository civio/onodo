window.App ||= {}

App.Visualization     = require './visualization.js'
App.VisualizationEdit = require './visualization-edit.js'
App.Story             = require './story.js'
App.Trix              = require 'script!trix'
Dropzone              = require 'dropzone'

$(document).ready ->

  $body = $('body')

  # visualizations
  if $body.hasClass('visualizations') 
    # /visualizations/:id
    if $body.hasClass('show')
      appVisualization = new App.Visualization $('body').data('visualization-id')
    # /visualizations/:id/edit
    else if $body.hasClass('edit')
      appVisualization = new App.VisualizationEdit $('body').data('visualization-id')
    appVisualization.render()
    $( window ).resize appVisualization.resize
  # stories
  else if $body.hasClass('stories') and ($body.hasClass('show') or $body.hasClass('edit'))
    # /stories/:id
    # /stories/:id/edit
    appStory = new App.Story $('body').data('story-id'), $('body').data('visualization-id'), $body.hasClass('edit')
    appStory.render()
    $( window ).resize appStory.resize

  # Activate tooltips
  $('[data-toggle="tooltip"]').tooltip()

  # Setup select-all checkbox in Chapter new/edit
  $('#relations_select_all').change (e) ->
    $('.table tbody input[type=checkbox]').prop 'checked', $(this).prop('checked')

  # Dropzones
  if $('#dropzone-preview-template').size() > 0
    Dropzone.options.chapterDropzone =
      autoProcessQueue: false
      uploadMultiple: false
      clickable: false
      maxFiles: 1
      acceptedFiles: 'image/*'
      paramName: 'chapter[image]'
      previewsContainer: '.media-left'
      previewTemplate: document.getElementById('dropzone-preview-template').innerHTML
      init: ->
        theDropzone = this
        @element.querySelector('input[type=submit]').addEventListener 'click', (e) ->
          e.preventDefault()
          e.stopPropagation()
          if theDropzone.getQueuedFiles().length > 0
            theDropzone.processQueue()
          else
            e.srcElement.parentElement.submit()
          return
        mockFile =
          name: '__mockfile__'
          size: 0
        imageUrl = $('.media-left').attr('data-image')
        if imageUrl
          @emit 'addedfile', mockFile
          @emit 'thumbnail', mockFile, imageUrl
          @emit 'complete', mockFile
          @files.push mockFile
        @on 'addedfile', ->
          $('#placeholder').hide()
          first_file = @files[0]
          if first_file.name == '__mockfile__' and first_file.size == 0
            @removeFile first_file
          return
        @on 'maxfilesexceeded', (file) ->
          @removeAllFiles()
          @addFile file
          return
        @on 'success', (file, response) ->
          window.location = response.location
          return
        return

  # Add file input feedback 
  # based on http://www.abeautifulsite.net/whipping-file-inputs-into-shape-with-bootstrap-3/
  $(document).on 'change', '.btn-file :file', () ->
      label     = $(this).val().replace(/\\/g, '/').replace(/.*\//, '')
      $(this).parent().siblings('.btn-file-output').html label