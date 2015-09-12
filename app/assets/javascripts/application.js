// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require foundation
//= require turbolinks
//= require_tree .

// $(function(){ $(document).foundation(); });

var ready;
ready = function() {

  $(document).foundation();
  var left_menu = $('.left-off-canvas-menu');
  var right_menu = $('.right-off-canvas-menu');

  $(document).on('resize', function() {
    // Beware with resize handlers...
    //  Throttle & consolidate #perfmatters
    left_menu.height($(this).height());
    right_menu.height($(this).height());
  });

  // Initialize height
  $(document).trigger('resize');

};

$(document).ready(ready);
$(document).on('page:load', ready);
