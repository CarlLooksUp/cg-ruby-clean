function stripeResponseHandler(status, response) {
  var form = $('.requires-payment');

  if (response.error) {
    //show error text
    $('.alert-content').empty().append($('<div>').text(response.error.message).prop('class', 'alert alert-warning'));
    $('#cc-data').addClass('has-warning');
    $('html, body').animate({
      scrollTop: 0
    }, 250);
    form.find('button').prop('disabled', false);
  } else {
    var token = response.id;
    form.append($('<input type="hidden" name="stripeToken" />').val(token));
    form.submit();
  }
}

function buildStatusIcon(id) {
    var statusId = id + 'status';
    var formGroup = $('#' + id).parent().parent();
    if($('#' + statusId).length == 0) {
      formGroup.append('<div class="col-md-1 status-icon"><span id="' + statusId + '" class="glyphicon glyphicon-pencil"></span></div>');
    } else {
      $('#' + statusId).attr('class', 'glyphicon glyphicon-pencil');
    }
}

function okStatusIcon(id) {
  var statusId = id + 'status';
  $('#' + statusId).attr('class', 'glyphicon glyphicon-ok');
}

function invalidStatusIcon(id) {
  var statusId = id + 'status';
  $('#' + statusId).attr('class', 'glyphicon glyphicon-remove');
}

function highlightCardType(content) {
  var cardType = Stripe.card.cardType(content);
  var typeId = cardTypeToId(cardType);
  $('.highlight').attr('class', 'cc-icon grey');
  $(typeId).attr('class', 'cc-icon highlight');
}

function cardTypeToId(type) {
  return '#' + type.toLowerCase().replace(/ /g, '_');
}

function filterBase (element) {
  return element != "null";
}

function baseText(text) {
  var str = text;
  var re = /\w+/;
  var retText = re.exec(str);
  return retText[0];

}

function searchText(text) {
  var str = text;
  var re = /\w+/;
  var base = [];

  for (i=0; i<=str.length-1; i++) {
    var cleanStr = re.exec(str[i]);
    base[i] = re.exec(cleanStr);  
  };

  var retQuery = base.filter(filterBase);
  return retQuery.join(" & ");;
}

function searchSplit(query) {
  var str = query;
  var resultArr = str.split(" ");
  return resultArr;
}

function $search_ajax (page_number) {
      var content = $('#bus_container');
      var pagination = $('#bus_page');
      var search_title = $('#search-title');
      var search_container = $('#search-container');
      var search_val = $('#search').val();
      var search_query = searchText(searchSplit(search_val));

      if (search_query == '') { 
          $('#search').val('');   
        } else {
          $.ajax ({
            url: '/search',
            dataType: 'script',
            type: 'GET',
            beforeSend: function() {
                document.getElementById('submit_search').focus();
                $('#bus_table').remove();

                search_container.animate({height: '145px', marginTop: '0px'},400, function(){
                  search_title.css('display','none');
                  content.css('display','block');
                });
                pagination.css('display','none');
                content.append('<div id="working"><img alt="Search Load" id="search-logo" src="/assets/search_load.gif"></div>');
                var working = $('#working');
                $('DIV#result-count').html('');
            },
            complete: function() {
                working.remove();
                pagination.css('display','block');
            },  
            data: { state_id: $('#state_filter').val(),
                  search: search_query,
                  page: page_number,
                  source: $('#source_filter').val() }
          });
      }; 
    }


$(function() {
  $('[data-toggle="tooltip"]').tooltip();
  
  $('.collapse').collapse({
    toggle: false
  });

  $("#business_in_use-true").click(function(){
    $('#used').collapse('show');
    $('#not-used').collapse('hide');
    $('#in-use-disclaimer-box').collapse('hide');
  });
  $("#business_in_use-false").click(function(){
    $('#used').collapse('hide');
    $('#not-used').collapse('show');
    $('#in-use-disclaimer-box').collapse('show');
  });
  $("#business_is_interstate-true").click(function() {
    $('#interstate').collapse('show');
  });
  $("#business_is_interstate-false").click(function() {
    $('#interstate').collapse('hide');
  });

  $('.form-tooltip-icon').tooltip({ delay: {show: 50, hide: 300} }).on(
    "hide.bs.tooltip", function() {
      var tooltipTrigger = $(this);
      var tooltipBox = tooltipTrigger.parent().find('.tooltip');
      if (tooltipBox.is(":hover")) {
        tooltipBox.mouseleave(function () {
          setTimeout(function() { tooltipTrigger.tooltip("hide") }, 100);
        });
        return false;
      } else {
        return true;
      }
    }
  );

  $('select').selectpicker();

  //initialize Stripe button
  var form = $('.requires-payment');
  var csrf_token = $('meta[name="csrf-token"]').attr('content');

  //bind stripe token creation to form submission
  form.submit( function(e) {
    //if this has gone through before, submit the form w/o further processing
    if($('input[name=stripeToken]').length) return true;

    //if the coupon code is invalid then stop submission
    $.ajax({
      url: '/coupon_check',
      dataType: 'json',
      type: 'POST',
      data: { coupon_code: $('#coupon_code_').val() },
      success: function(response) {
        if(!$('#coupon_code_').val() || response.valid_code) {
          $('#coupon_code_').parent().parent().removeClass('has-error');
          if($('#limited-disclaimer').prop('checked')) {
            $('#limited-disclaimer').parent().parent().removeClass('has-error');
            $(this).find('button').prop('disabled', true);
            Stripe.setPublishableKey( $('#stripe_pkey_').val() );

            Stripe.card.createToken(form, stripeResponseHandler);
          } else {
            $('#limited-disclaimer').parent().parent().addClass('has-error');
          }
	} else { //coupon is invalid
          $('#coupon_code_').parent().parent().addClass('has-error');
        }
      }
    });
    return false;
  });

  //Check for valid coupon code
  $('#coupon_code_').bind('input propertychange', function() {
    buildStatusIcon('coupon_code_');
    $.ajax({
      url: '/coupon_check',
      dataType: 'json',
      type: 'POST',
      data: { coupon_code: $('#coupon_code_').val() },
      success: function(response) {
        if(response.valid_code) {
          okStatusIcon('coupon_code_');
        } else {
          $('#code_box_status').attr('class', 'glyphicon glyphicon-remove');
        }
      },
    });
  });

  //Check for valid credit card details
  $('#cc_num_').bind('input propertychange', function() {
    buildStatusIcon('cc_num_');
    var content = $('#cc_num_').val()
    highlightCardType(content);
    if (Stripe.card.validateCardNumber(content)) {
      okStatusIcon('cc_num_');

    } else {
      invalidStatusIcon('cc_num_');
    }
  });

  $('#nextBtn').click(function() {
    var page = $('div.page-in');
    var pageIcon = $('img.page-in');
    var pageNum = page.data('page');
    var valid = true;
    $('#nextBtn button').button('loading');
    $('.help-block').remove();

    if(pageNum == 0) {
      var form = $('#new_user');
      var formData = form.serializeArray();
      if(!$('#signup_disclaimer').prop('checked')) {
        $('#signup_disclaimer').parent().parent().addClass('has-error');
        $('#nextBtn button').button('reset');
        return false;
      }
      $.ajax({
        url: form.attr('action'),
        dataType: 'json',
        type: 'POST',
        data: formData,
        error: function(response) {
          form.find('.form-group').removeClass('has-error');
          for(var key in response.responseJSON.errors) {
            $('.user_' + key).addClass('has-error');
            $('.user_' + key).append('<span class="help-block">' + key + ' ' + response.responseJSON.errors[key] + '</span>');
          }
          $('#nextBtn button').button('reset');
        },
        success: function(response) {
          form.find('.form-group').removeClass('has-error');
          page.attr('class', 'page-hide');
          pageIcon.attr('class', 'page-' + pageNum + '-icon page-hide');
          pageNum = pageNum + 1;
          if(pageNum == 2) {
            $('#prevBtn button').prop('disabled', false);
            $('#prevBtn').show();
          }
          if(pageNum == 3) {
            $('#nextBtn button').prop('disabled', false);
            $('#nextBtn').hide();
            $('#regSubmit').show();
          }
          $('#page' + pageNum).attr('class', 'page-in');
          $('.page-' + pageNum + '-icon').attr('class', 'page-' + pageNum + '-icon page-in');
	  $('#nextBtn button').button('reset');
        }
      });
    } else {
      var form = $('#new_business')
      var formData = form.serializeArray();
      formData.push( { name: 'form_page', value: pageNum });
      formData.push( { name: 'business[proof_of_use_file]', value: $('#business_proof_of_use_file').val() });
      $.ajax({
        url: '/businesses/page_errors/',
        dataType: 'json',
        type: 'POST',
        data: formData,
        success: function(response) {
          page.find('.form-group').removeClass('has-error');
          if(!$.isEmptyObject(response.errors)) {
            for(var key in response.errors) {
              $('.business_' + key).addClass('has-error');
            }
          } else if ($('#in-use-disclaimer').is(":visible") && !$('#in-use-disclaimer').prop('checked')) {
            $('#in-use-disclaimer-box').addClass('has-error');
          } else {
            page.attr('class', 'page-hide');
            pageIcon.attr('class', 'page-' + pageNum + '-icon page-hide');
            pageNum = pageNum + 1;
            if(pageNum == 2) {
              $('#prevBtn button').prop('disabled', false);
              $('#prevBtn').show();
            }
            if(pageNum == 3) {
              $('#nextBtn button').prop('disabled', false);
              $('#nextBtn').hide();
              $('#regSubmit').show();
            }
            $('#page' + pageNum).attr('class', 'page-in');
            $('.page-' + pageNum + '-icon').attr('class', 'page-' + pageNum + '-icon page-in');
          }
          $('#nextBtn button').button('reset');
        }
      });
    }
  });

  $('#prevBtn').click(function() {
    var page = $('div.page-in');
    var pageIcon = $('img.page-in');
    var pageNum = page.data('page');
    page.attr('class', 'page-hide');
    pageIcon.attr('class', 'page-' + pageNum + '-icon page-hide');
    pageNum = pageNum - 1;
    if(pageNum == 1) {
      $('#prevBtn button').prop('disabled', true);
      $('#prevBtn').hide();
    }
    if(pageNum == 2) {
      $('#nextBtn button').prop('disabled', false);
      $('#nextBtn').show();
      $('#regSubmit').hide();
    }
    $('#page' + pageNum).attr('class', 'page-in');
    $('.page-' + pageNum + '-icon').attr('class', 'page-' + pageNum + '-icon page-in');
  });

  $('#regSubmit').hide();
  $('#prevBtn button').prop('disabled', true);
  $('#prevBtn').hide();

  $('#state_filter, #source_filter').change(function() {
    var content = $('#bus_container')
    var search_val = $('#search').val();
    var search_query = searchText(searchSplit(search_val));
    var pagination = $('#bus_page');

    if (search_query == '') { 
        $('#search').val('');
      
      } else {
      $.ajax ({
        url: '/search',
        dataType: 'script',
        type: 'GET',
        beforeSend: function() {
          $('#bus_table').remove();
          content.append('<div id="working"> <img alt="Search Load" id="search-logo" src="/assets/search_load.gif"></div>');
          var working = $('#working');
          $('DIV#result-count').html('');
          pagination.css('display','none');
        },
        complete: function() {
         working.remove();
         pagination.css('display','block');
        },
        data: { state_id: $('#state_filter').val(),
              search: $('#search').val(),
              source: $('#source_filter').val() }
    });
    };
  });

  $('TD#source-note').hover(
    function() {
      var source_color = $(this).css('border-left-color');
      var source_note = $(this).attr("data-source-note");
      $(this).html('<div id="source-pop-out"></div>');
      $('DIV#source-pop-out').animate({width: '150px'},200, function() {
          $(this).css('background-color',source_color);
          $(this).html(source_note);
      }); 
    },
    function() {
      $('DIV#source-pop-out').animate({width: '1px'}, 150, function() { 
        $(this).html('');
        $(this).remove();
      });
    });

  $('INPUT#submit_search').on('click', function(ev){
      ev.preventDefault();

      var content = $('#bus_container');
      var pagination = $('#bus_page');
      var search_title = $('#search-title');
      var search_container = $('#search-container');
      var search_val = $('#search').val();
      var search_query = searchText(searchSplit(search_val));
      
      if (search_query == '') { 
        $('#search').val('');   
      } else {
        $.ajax ({
        url: '/search',
        dataType: 'script',
        type: 'GET',
        beforeSend: function() {
          document.getElementById('submit_search').focus();
          $('#bus_table').remove();

          search_container.animate({height: '145px', marginTop: '0px'},400, function(){
            search_title.css('display','none');
            content.css('display','block');
          });

          pagination.css('display','none');
          /*working.css('display','block'); */
          content.append('<div id="working"> <img alt="Search Load" id="search-logo" src="/assets/search_load.gif"></div>');
          var working = $('#working');
          $('DIV#result-count').html('');
        },
        complete: function() {
          /*working.css('display','none');*/
          working.remove();
          pagination.css('display','block');
        },  
        data: { state_id: $('#state_filter').val(),
              search: search_query,
              source: $('#source_filter').val() }
      });
    };
  });

});


