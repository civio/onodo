(($) ->

  addHandsOnTable = ->
    console.log "addHandsOnTable"
    data = [
      ["", "Ford", "Volvo", "Toyota", "Honda"],
      ["2014", 10, 11, 12, 13],
      ["2015", 20, 11, 14, 13],
      ["2016", 30, 15, 12, 13]
    ]

    container = document.getElementById 'visualization-table-nodes'
    hot = new Handsontable(container, {
      data: data,
      minSpareRows: 1,
      rowHeaders: true,
      colHeaders: true,
      contextMenu: true
    })

  onResizeHandler = ->
    console.log "resize", $(window).height()
    windowHeight = $(window).height()
    graphHeight = windowHeight - 50 - 64 - 64
    $('.visualization-graph-container').height graphHeight
    $('.visualization-table').css 'top', graphHeight+64
    # $('.visualization-table').height( windowHeight - 64 );
    $('.footer').css 'top', graphHeight+64

  $ ->
    
    #addHandsOnTable()

    $('#btn-visualization-preview').click ->
      $('html, body').stop().animate({scrollTop: 50}, '500')

    onResizeHandler()
    
    $( window ).resize onResizeHandler

) jQuery