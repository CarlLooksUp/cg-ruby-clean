$(function() {
  $('.coupon_email_modal').on('show.bs.modal', function(event) {
    $('#email_coupon_id').val($(event.relatedTarget).data('coupon-id'));
  });
});
