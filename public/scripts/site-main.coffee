$(document).ready ->
  $("#ads-list").one "mouseover", reload_ads_list
  clear_ads_menu()

clear_ads_menu = ->
  $("#ads-list ul").children().remove()
  $("<li id=\"spinner\" class=\"detail-item\"></li>").appendTo $("#ads-list ul")
  add_spinner_to_ads_list()
  toggle_ads_list_refresh_button true

reload_ads_list = ->
  clear_ads_menu()
  toggle_ads_list_refresh_button true
  $.getJSON "/list", (data) ->
    window.all_ads = data
    add_ads_list_to_navbar()
    toggle_ads_list_refresh_button false

  false

toggle_ads_list_refresh_button = (turn_off) ->
  if turn_off
    $("#ads-list #refresh-button").addClass("off").removeClass "on"
    $("#ads-list #refresh-button a").text "     "
  else
    $("#ads-list #refresh-button").addClass("on").removeClass "off"
    $("#ads-list #refresh-button a").text "(refresh)"

add_ads_list_to_navbar = ->
  $("#ads-list ul").children().remove()
  elem_ads_list = $("#ads-list ul")
  ads_list_text = ""
  for index of window.all_ads
    ad = window.all_ads[index]
    ads_list_text += "<li class=\"detail-item\"><a href=\"/display/" + ad.id + "\">" + ad.title + "</a></li>"
  $(ads_list_text).appendTo elem_ads_list

add_spinner_to_ads_list = ->
  opts =
    lines: 11 # The number of lines to draw
    length: 3 # The length of each line
    width: 2 # The line thickness
    radius: 5 # The radius of the inner circle
    corners: 1 # Corner roundness (0..1)
    rotate: 0 # The rotation offset
    color: "#000" # #rgb or #rrggbb
    speed: 1 # Rounds per second
    trail: 60 # Afterglow percentage
    shadow: false # Whether to render a shadow
    hwaccel: false # Whether to use hardware acceleration
    className: "spinner" # The CSS class to assign to the spinner
    zIndex: 2e9 # The z-index (defaults to 2000000000)
    top: "auto" # Top position relative to parent in px
    left: "auto" # Left position relative to parent in px

  spinner = new Spinner(opts).spin(document.getElementById("spinner"))
