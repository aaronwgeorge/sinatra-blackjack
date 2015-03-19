$(document).ready(function() {
  
  $(document).on("click", "#hit input", function() {  
    $.ajax({
      type: 'POST',
      url: '/player/hit'
    }).done(function(msg) {
      $("#game").replaceWith(msg);
    });
    return false;  
  });

  $(document).on("click", "#stay input", function() {  
    $.ajax({
      type: 'POST',
      url: '/dealer'
    }).done(function(msg) {
      $("#game").replaceWith(msg);
    });
    return false;  
  });

  $(document).on("click", "#dealer-hit input", function() {  
    $.ajax({
      type: 'POST',
      url: '/dealer/hit'
    }).done(function(msg) {
      $("#game").replaceWith(msg);
    });
    return false;  
  });

});