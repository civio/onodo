class VisualizationModalNodeImage extends Backbone.View

  el: '#table-image-modal'
  index:      null
  nodeId:     null
  image:      null
  imageAdded: false

  show: (index, id) ->
    @index      = index
    @nodeId     = id
    @imageAdded = false
    console.log 'showImageModal', index, @$el
    # Load description edit form via ajax in modal
    @$el.find('.modal-body').load '/nodes/'+@nodeId+'/edit/image/', @onModalLoaded
    # Show modal
    @$el.modal 'show'

  onModalLoaded: () =>
    # Upload photo
    if @$el.find('.step-upload').size() > 0
      console.log 'Upload photo'
      # Disable buttons on form submit
      @$el.find('#node-image-form').on 'submit', @onSubmitForm
      # Add on submit handler to save new description via model
      @$el.find('#uploadTarget').on 'load', @onImageUploaded
    # Edit Photo
    else
      @$el.find('#delete-image').on 'click', @onDeleteImage

  onModalHidden: (e) =>
    # Remove Events Listeners
    @$el.find('#node-image-form').off             'submit'
    @$el.find('#uploadTarget').off                'load'
    @$el.find('.step-confirm #add-image').off     'click'
    @$el.find('.step-confirm #change-image').off  'click'
    @$el.find('#delete-image').off                'click'
    @$el.off                                      'hide.bs.modal'
    # Delete image when modal hidden & image has not be confirmed
    unless @imageAdded
      console.log 'delete image'
      @.trigger 'delete', {id: @nodeId}

  onSubmitForm: (e) =>
    @$el.find('.step-upload .actions a.btn-invert').hide()
    @$el.find('.step-upload input[type="submit"]').addClass('disabled')

  onImageUploaded: (e) =>
    e.preventDefault()
    console.log 'onImageModalUploadConfirm'
    @image = $.parseJSON($(e.target).contents().text()).image
    @$el = $('#table-image-modal')
    # Hide Step Upload & Show Step Confirm
    @$el.find('.step-upload').addClass('hide')
    @$el.find('.step-confirm').removeClass('hide').children('#node-img').attr('src', @image.huge.url)
    # Add Image Btn event handler
    @$el.find('.step-confirm #add-image').on 'click', @onAddImage
    # Change Image Btn event handler
    @$el.find('.step-confirm #change-image').on 'click', @onChangeImage
    @$el.on 'hide.bs.modal', @onModalHidden

  onAddImage: (e) =>
    e.preventDefault()
    @imageAdded = true
    @.trigger 'update', {index: @index, value: @image}
    #@syncTable = false  # desactivate syncronization with DB for changes in table
    #@syncTable = true  # activate again syncronization with DB for changes in table
    @$el.modal 'hide'

  onChangeImage: (e) =>
    e.preventDefault()
    # Reset Step Upload btns
    @$el.find('.step-upload .actions a.btn-invert').show()
    @$el.find('.step-upload input[type="submit"]').removeClass('disabled')
    # Hide Step Confirm & Show Step Upload
    @$el.find('.step-confirm').addClass('hide')
    @$el.find('.step-upload').removeClass('hide')

  onDeleteImage: (e) =>
    e.preventDefault()
    console.log 'Delete image'
    @.trigger 'update', {index: @index, value: null}
    @$el.modal 'hide'

module.exports = VisualizationModalNodeImage
