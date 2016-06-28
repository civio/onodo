$(document).ready(function(){

  //Cookie bar activate

  $.cookieBar();

  // Activate tooltips
  $('[data-toggle="tooltip"]').tooltip();

  // Setup select-all checkbox in Chapter new/edit
  $('#relations_select_all').change(function(e){
    $('.table tbody input[type=checkbox]').prop('checked', $(this).prop('checked'));
  });

  // Add file input feedback 
  // based on http://www.abeautifulsite.net/whipping-file-inputs-into-shape-with-bootstrap-3/
  $(document).on('change', '.btn-file :file', function() {
    var label = $(this).val().replace(/\\/g, '/').replace(/.*\//, '');
    $(this).parent().siblings('.btn-file-output').html(label);
  });

  // Listen click on Visualization Select Item to store visualization id & submit form
  $('.story-select-visualization-list .visualization-item').click(function(e){
    e.preventDefault();
    // Validate nstory name presence
    if ($('#story_name').val().trim() === '') {
      $('#story_name').focus();
      return;
    }
    // Store visualization id in hidden input
    $('#story_visualization_id').val( $(this).attr('href') );
    // Submit form
    $('#form-story-new').submit();
  });
});