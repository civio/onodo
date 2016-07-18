class VisualizationModalNodeImage extends Backbone.View

  el: '#table-image-modal'
  index:      null
  nodeId:     null
  image:      null
  imageAdded: false

  show: (index, id) ->
    @index      = index
    @nodeId     = id
    # Load description edit form via ajax in modal
    @$el.find('.modal-body').load '/nodes/'+@nodeId+'/edit/image/', @onModalLoaded
    # Show modal
    @$el.modal 'show'

  onModalLoaded: () =>
    # Get imageAdded based on src content of node-img
    @imageAdded = @$el.find('#node-img').attr('src') != undefined
    @$el.find('#uploadTarget').on 'load',             @onImageUploaded
    # Add Image Btn event handler
    @$el.find('#add-image').on 'click',               @onAddImage
    # Change Image Btn event handler
    @$el.find('#change-image').on 'click',            @onChangeImage
    # Delete Image Btn event handler
    @$el.find('#delete-image').on 'click',            @onDeleteImage
    # Modal hidden event
    @$el.on 'hide.bs.modal',                          @onModalHidden
    # Submit form when image selected in Browse btn
    @$el.find('#node_image').on 'change',             @onNodeImageUpdated
    @$el.find('#node_remote_image_url').on 'change',  @onNodeImageURLUpdated

  onNodeImageUpdated: (e) =>
    @$el.find('#upload-error-msg').addClass('hide')
    @$el.find('#node_remote_image_url').val('')
    @$el.find('#node-image-form').submit()

  onNodeImageURLUpdated: (e) =>
    #console.log 'node_remote_image_url change!', $(e.target).val()
    @$el.find('#upload-error-msg').addClass('hide')
    @$el.find('#node-image-form').submit()

  onImageUploaded: (e) =>
    e.preventDefault()
    #console.log 'onImageModalUploadConfirm', $.parseJSON($(e.target).contents().text())
    @image = $.parseJSON($(e.target).contents().text()).image
    if @image == null
      @$el.find('#upload-error-msg').removeClass('hide')
    # Show image preview & enable Add Image btn
    @$el.find('#node-img').attr('src', @image.big.url)
    @$el.find('#add-image').removeClass('disabled')
  
  onAddImage: (e) =>
    e.preventDefault()
    @addImage()
    @$el.modal 'hide'

  onChangeImage: (e) =>
    #console.log 'onChangeImage'
    e.preventDefault()
    # Hide Change & Delete btns & Show Upload contents
    @$el.find('#change-image, #delete-image').addClass('hide')
    @$el.find('#upload-description, #upload-btns, #add-image').removeClass('hide')
    # Remove image preview
    @$el.find('#node-img').attr('src', '')
    # remove current image if has one
    if @imageAdded
      @deleteImage()

  onDeleteImage: (e) =>
    e.preventDefault()
    #console.log 'Delete image'
    @deleteImage()
    @$el.modal 'hide'

  onModalHidden: (e) =>
    # Remove Events Listeners
    @$el.find('#uploadTarget').off    'load'
    @$el.find('#add-image').off       'click'
    @$el.find('#change-image').off    'click'
    @$el.find('#delete-image').off    'click'
    @$el.off                          'hide.bs.modal'
    @$el.find('#node_image').off      'change'
    # Delete image when modal hidden & image has not be confirmed
    unless @imageAdded
      #console.log 'delete image'
      @.trigger 'delete', {id: @nodeId}

  addImage: =>
    @.trigger 'update', {index: @index, value: @image}
    @imageAdded = true

  deleteImage: () ->
    @.trigger 'update', {index: @index, value: null}
    @imageAdded = false

module.exports = VisualizationModalNodeImage
