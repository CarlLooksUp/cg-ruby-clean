$(function (){
  //Password fields only show when user wants to change password
  $('.collapse').collapse({
    //toggle: false
  });
  $("#password_toggle").click(function(){
    $('#change_password').collapse('toggle'); 
    tag = $('#new_password');
    if (tag.val() == "true") {
      tag.val("false");
    } else {
      tag.val("true");
    }
  });

  $('#new_user').submit(function() {
    if($('#signup_disclaimer').prop('checked')) {
      return true;
    } else {
      $('#signup_disclaimer').parent().parent().addClass('has-error');
      return false;
    }
  });
});
