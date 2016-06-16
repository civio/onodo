require 'bootstrap-datepicker'

$(document).ready ->
  
  # Setup datepickers
  $('#datepicker-from-to, #datepicker-at').datepicker {
    format: 'dd/mm/yyyy'
    autoclose: true
    language: 'en'
  }
  
  # Setup data type selector
  $('.date-type-selector input').change (e) ->
    $('.date-forms .form-default').addClass 'hide'
    $('#'+$(e.target).val()).removeClass 'hide'