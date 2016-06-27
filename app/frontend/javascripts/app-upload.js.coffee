Dropzone = require 'dropzone'

$(document).ready ->

  # Dropzones
  
  # chapter
  if $('#chapter-dropzone').size() > 0
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

  # user
  if $('#user-dropzone').size() > 0
    Dropzone.options.userDropzone =
      autoProcessQueue: false
      uploadMultiple: false
      clickable: false
      maxFiles: 1
      acceptedFiles: 'image/*'
      paramName: 'user[avatar]'
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