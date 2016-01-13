$( function() {
  var select = $("#top_level_product_type_goods_product_type_id, #top_level_product_type_services_product_type_id");
  select.change(function(e) {
    $("#product_product_types").data("scope", "descendants_of(" + $(e.target).val() + ")")
                              .prop('disabled', false)
                              .removeClass('disabled');
  });
  product_form = $('#new_product');

  $('#product_business_name').on('autocompletecreate', function(e) {
    $(e).autocomplete('option', 'minLength', 0);
  });

  $('#product_add_and_continue').click(function(e) {
    e.preventDefault();
    $.ajax({
        url: $('#product_add_and_continue').data('action'),
        dataType: 'json',
        type: 'POST',
        data: new FormData(product_form[0]),
        processData: false,
        contentType: false,
        error: function(response) {
          product_form.find('.form-group').removeClass('has-error');
          for(var key in response.errors) {
            $('.product_' + key).addClass('has-error');
            $('.product_' + key).append('<span class="help-block">' + key + ' ' + response.errors[key] + '</span>');
          }
        },
        success: function(response) {
          product_form.trigger("reset");
          $('#cart').html(response.cartHTML);
        }
      });
  });

  $('#product_add_and_checkout').click(function(e) {
    e.preventDefault();
    $.ajax({
        url: $('#product_add_and_checkout').data('action'),
        dataType: 'html',
        type: 'POST',
        data: new FormData(product_form[0]),
        processData: false,
        contentType: false,
        error: function(response) {
          product_form.find('.form-group').removeClass('has-error');
          for(var key in response.errors) {
            $('.product_' + key).addClass('has-error');
            $('.product_' + key).append('<span class="help-block">' + key + ' ' + response.errors[key] + '</span>');
          }
        },
        success: function() {
          window.location = "/checkout"
        }
    });
  });

  //prevent form submission on Enter
  product_form.keypress(function(e) {
    if (e.keyCode ==13) {
      e.preventDefault();
    }
  });

  //toggle Goods/Services select box
  $('#product_is_service-true').click(function() {
    $('#goodsSelect').addClass('hide');
    $('#servicesSelect').removeClass('hide').prop('disabled', 'false');
  });
  $('#product_is_service-false').click(function() {
    $('#servicesSelect').addClass('hide');
    $('#goodsSelect').removeClass('hide');
  });
});
