datepicker   = require 'bootstrap-datepicker'
moment       = require 'moment'
moment_range = require 'moment-range'

$(document).ready ->

  date_format = 'DD/MM/YYYY'
  
  # Setup datepickers
  $('#datepicker-from-to').datepicker {
    format:    date_format.toLowerCase()
    autoclose: true
    clearBtn:  true
    language:  'en'
  }
  
  # Setup data type selector
  $('#datepicker-from-to input').change (e) ->
    # show all
    $('.visualization-table table tbody tr').removeClass 'hide'
    # filter if we have a filter rango (both from & to dates)
    # TODO!!! Por ahora sólo filtramos si hay filter_from y filter_to -> tenemos que plantear los casos que sólo hay from o to
    if $('#chapter_date_from').val() and $('#chapter_date_to').val()
      filter_from  = moment $('#chapter_date_from').val(), date_format
      filter_to    = moment $('#chapter_date_to').val(), date_format
      filter_range = moment.range filter_from, filter_to
      #console.log 'date change', filter_from, filter_to, filter_range
      $('.visualization-table table tbody tr ').each ->
        date_from = if $(this).data('date-from') then moment($(this).data('date-from'), date_format) else null
        date_to   = if $(this).data('date-to') then moment($(this).data('date-to'), date_format) else null 
        date_at   = if $(this).data('date-at') then moment($(this).data('date-at'), date_format) else null 
        if date_from and date_to
          #console.log 'case 1', date_from, date_to
          date_range = moment.range date_from, date_to
          if !date_range.overlaps(filter_range)
            $(this).addClass 'hide'
        else if date_from
          #console.log 'case 2', date_from
          if !date_from.isBefore(filter_to)
            $(this).addClass 'hide'
        else if date_to
          #console.log 'case 3', date_to
          if !date_to.isAfter(filter_from)
            $(this).addClass 'hide'
        else if date_at
          #console.log 'case 4', date_at
          if !date_at.isBetween(filter_from,filter_to, null, '[]')
            $(this).addClass 'hide'
  