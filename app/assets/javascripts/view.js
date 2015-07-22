$(document).on('ready page:load', function() {
  $('.viewtag').click(function() {  
    var $cur_td = $(this);
    var word = $cur_td.text(); 
    $.ajax({
      async: true ,
      url : '../words/view/' + word ,
      type: "GET",
      data: {id : $cur_td.id},
      dataType : 'json',
      success : function(data, dataType) {  
        $(".modal-header").find("#result_en").html('<span>'+ data.en + '</span>');
        $(".modal-body").find("#result_en").html('<span>'+ data.en + '</span>');
        $(".modal-body").find("#result_ja").html('<span>'+ data.ja + '</span>');
        $(".modal-footer").find("result_id").val(data.id);
        $('#myModal').modal('show');
      }
    }); 
  }); 
}); 


