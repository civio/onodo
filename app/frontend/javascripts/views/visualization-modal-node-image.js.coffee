class VisualizationModalNodeImage extends Backbone.View

  el: '#table-image-modal'

  show: (index, id) ->
    console.log 'showImageModal', index, @$el
    # Load description edit form via ajax in modal
    @$el.find('.modal-body').load '/nodes/'+id+'/edit/image/', () =>
      # Upload photo
      if @$el.find('.step-upload').size() > 0
        console.log 'Upload photo'
        # Disable buttons on form submit
        @$el.find('.form-default').on 'submit', (e) =>
          @$el.find('.step-upload .actions a.btn-invert').hide()
          @$el.find('.step-upload input[type="submit"]').addClass('disabled')
        # Add on submit handler to save new description via model
        @$el.find('#uploadTarget').on 'load',  (e) =>
          e.preventDefault()
          console.log 'onImageModalUploadConfirm'
          image = $.parseJSON($(e.target).contents().text()).image
          @$el = $('#table-image-modal')
          # Hide Step Upload & Show Step Confirm
          @$el.find('.step-upload').addClass('hide')
          @$el.find('.step-confirm').removeClass('hide').children('#node-img').attr('src', image.big.url)
          # Add Image Btn event handler
          @$el.find('.step-confirm #add-image').one 'click', (e) =>
            e.preventDefault()
            @.trigger 'update', {index: index, value: image}
            #@syncTable = false  # desactivate syncronization with DB for changes in table
            #@syncTable = true  # activate again syncronization with DB for changes in table
            @$el.modal 'hide'
          # Change Image Btn event handler
          @$el.find('.step-confirm #change-image').one 'click', (e) =>
            e.preventDefault()
            # Reset Step Upload btns
            @$el.find('.step-upload .actions a.btn-invert').show()
            @$el.find('.step-upload input[type="submit"]').removeClass('disabled')
            # Hide Step Confirm & Show Step Upload
            @$el.find('.step-confirm').addClass('hide')
            @$el.find('.step-upload').removeClass('hide')
      # Edit Photo
      else
        @$el.find('#delete-image').one 'click', (e) =>
          e.preventDefault()
          console.log 'Delete image'
          @.trigger 'update', {index: index, value: null}
          @$el.modal 'hide'
    # Show modal
    @$el.modal 'show'

module.exports = VisualizationModalNodeImage
