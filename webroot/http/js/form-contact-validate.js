jQuery(document).ready(function(){
		
		jQuery("<img>")
        .attr("src","http://www.yourinspirationweb.com/wp-content/themes/yiw/images/clear.gif")
        .prependTo('body');
        
        jQuery('<div></div>')
        .insertBefore('#log')
            .attr('id','log_wait')
            .css('display','none')
            .addClass('ajax-loading')
            .ajaxStart(function(){jQuery(this).show();})
            .ajaxStop(function(){jQuery(this).hide();});
            
            
        jQuery('#contacts').submit(function() {
            jQuery.post('include/inc_sendmail.php',jQuery(this).serialize(), function(data){
            jQuery('#log').empty();
            jQuery('<div></div>')
            .attr('id','log_res')
            .appendTo('#log')
            .html(data);
        });
        return false;
    });
});