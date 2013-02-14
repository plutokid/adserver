$(document).ready(function() {
    $('#ads-list').one('mouseover', reload_ads_list);
    clear_ads_menu();
});

clear_ads_menu = function() {
    $('#ads-list ul').children().remove();
    $('<li id="spinner" class="detail-item"></li>').appendTo($('#ads-list ul'));
    add_spinner_to_ads_list();
    toggle_ads_list_refresh_button(true);
}

reload_ads_list = function() {
    clear_ads_menu();
    toggle_ads_list_refresh_button(true);
    $.getJSON('/list', function(data) {
        window.all_ads = data;
        add_ads_list_to_navbar();
        toggle_ads_list_refresh_button(false);
    });
    return false;
}

toggle_ads_list_refresh_button = function(turn_off) {
    if (turn_off) {
        $('#ads-list #refresh-button').addClass('off').removeClass('on');
        $('#ads-list #refresh-button a').text("     ");
    } else {
        $('#ads-list #refresh-button').addClass('on').removeClass('off');
        $('#ads-list #refresh-button a').text('(refresh)');
    }
}

add_ads_list_to_navbar = function() {
    $('#ads-list ul').children().remove();
    var elem_ads_list = $('#ads-list ul');
    var ads_list_text = '';
    for (index in window.all_ads) {
        var ad = window.all_ads[index];
        ads_list_text += '<li class="detail-item"><a href="/display/' + ad.id + '">' + ad.title + '</a></li>';
    }
    $(ads_list_text).appendTo(elem_ads_list);
}


add_spinner_to_ads_list = function() {
    var opts = {
        lines: 11, // The number of lines to draw
        length: 3, // The length of each line
        width: 2, // The line thickness
        radius: 5, // The radius of the inner circle
        corners: 1, // Corner roundness (0..1)
        rotate: 0, // The rotation offset
        color: '#000', // #rgb or #rrggbb
        speed: 1, // Rounds per second
        trail: 60, // Afterglow percentage
        shadow: false, // Whether to render a shadow
        hwaccel: false, // Whether to use hardware acceleration
        className: 'spinner', // The CSS class to assign to the spinner
        zIndex: 2e9, // The z-index (defaults to 2000000000)
        top: 'auto', // Top position relative to parent in px
        left: 'auto' // Left position relative to parent in px
    };
    var spinner = new Spinner(opts).spin(document.getElementById('spinner'));
}