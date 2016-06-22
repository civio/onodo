require 'bootstrap-datepicker'

$(document).ready ->
  
  # Setup datepickers
  $('#datepicker-from-to, #datepicker-at').datepicker {
    format:    'dd/mm/yyyy'
    autoclose: true
    clearBtn:  true
    language:  'en'
  }
  
  # Setup data type selector
  $('.date-type-selector input').change (e) ->
    console.log 'date change', e
    #$('#'+$(e.target).val()).removeClass 'hide'