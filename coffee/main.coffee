$ ->
  $(window).scrollTop(90000)
  $(window).scroll ->
    if $(window).scrollTop() < 50000
      $(window).scrollTop(90000)
