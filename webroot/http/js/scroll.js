jQuery(document).ready(function(){
  jQuery('#nav a[href*=#]').click(function() {
    if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'')
    && location.hostname == this.hostname) {
      var $target = jQuery(this.hash);
      $target = $target.length && $target
      || $('[name=' + this.hash.slice(1) +']');
      if ($target.length) {
        var targetOffset = $target.offset().top;
        jQuery('html,body')
        .animate({scrollTop: targetOffset}, 1000);
       return false;
      }
    }
  });
});
