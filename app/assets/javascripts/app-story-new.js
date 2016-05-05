$(document).ready(function(){

  // Listen click on Visualization Select Item to store visualization id & submit form
  $('.story-select-visualization-list .visualization-item').click(function(e){
    e.preventDefault();
    // Store visualization id in hidden input
    $('#story_visualization').val( $(this).attr('href') );
    // Submit form
    $('#form-story-new').submit();
  });
});