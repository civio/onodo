$(document).ready(function(){

  //Cookie bar activate

  $.cookieBar({
    //Configuration
    message: 'We use cookies to track usage and preferences.', //Message displayed on bar
    acceptButton: true, //Set to true to show accept/enable button
    acceptText: 'I Understand', //Text on accept/enable button
    //acceptFunction: null, //Function on accept/enable button
    //declineButton: false, //Set to true to show decline/disable button
    //declineText: 'Disable Cookies', //Text on decline/disable button
    //declineFunction: null, //Function on decline/disable button
    //policyButton: false, //Set to true to show Privacy Policy button
    //policyText: 'Privacy Policy', //Text on Privacy Policy button
    //policyURL: '/privacy-policy/', //URL of Privacy Policy
    autoEnable: true, //Set to true for cookies to be accepted automatically. Banner still shows
    //acceptOnContinue: false, //Set to true to silently accept cookies when visitor moves to another page
    //acceptOnScroll: false, //Set to true to silently accept cookies when visitor scrolls
    //acceptAnyClick: false, //Set to true to silently accept cookies when visitor click on any place
    expireDays: 365, //Number of days for cookieBar cookie to be stored for
    //renewOnVisit: false, //Set to true to renew the cookie on every visit
    //forceShow: false, //Force cookieBar to show regardless of user cookie preference
    effect: 'slide', //Options: slide, fade, hide
    element: 'body', //Element to append/prepend cookieBar to. Remember "." for class or "#" for id.
    //append: false, //Set to true for cookieBar HTML to be placed at base of website. Actual position may change according to CSS
    fixed: true, //Set to true to add the class "fixed" to the cookie bar. Default CSS should fix the position
    bottom: true, //Force CSS when fixed, so bar appears at bottom of website
    //zindex: '', //Can be set in CSS, although some may prefer to set here
    //domain: String(window.location.hostname), //Location of privacy policy
    //referrer: String(document.referrer) //Where visitor has come from
  });

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