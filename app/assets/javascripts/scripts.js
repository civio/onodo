$(document).ready(function(){

  // Activate tooltips
  $('[data-toggle="tooltip"]').tooltip();

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