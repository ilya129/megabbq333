$(document).ready(function(){
  $('.owl-carousel').owlCarousel({
    items: 5,
    nav: true,
    loop: $('.owl-carousel').data('count') > 5
  });
});

