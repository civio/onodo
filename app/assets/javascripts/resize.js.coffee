(($) ->
  
  onResizeHandler = ->
    console.log "resize", $(window).height()
    windowHeight = $(window).height()
    graphHeight = windowHeight - 50 - 64 - 64
    $('.visualization-graph-container').height graphHeight
    $('.visualization-table').css 'top', graphHeight+64
    # $('.visualization-table').height( windowHeight - 64 );
    $('.footer').css 'top', $('.visualization-graph-container').height()+64

  $ ->
    $('#btn-visualization-preview').click ->
      $('html, body').stop().animate({scrollTop: 50}, '500')
    onResizeHandler()
    $( window ).resize onResizeHandler

) jQuery