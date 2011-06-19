var Bribable = {
  showMessages: false,
  initialLocation : null,
  map: null,
  base_location : new google.maps.LatLng(40.69847032728747, -73.9514422416687),
  browserSupportFlag: new Boolean(),
  circle: null,

  resetFormValues : function(map) {
    $('input#long').val(map.getCenter().lng());
    $('input#lat').val(map.getCenter().lat());
  },

  saveInitialLocation : function(lat, long) {
    Bribable.initialLocation = new google.maps.LatLng(lat, long);
    $('input#initial_lat').val(lat);
    $('input#initial_long').val(long);
  },

  handleNoGeolocation : function(errorFlag) {
    if (errorFlag == true) {
      Bribable.initialLocation = base_location;
      contentString = "Error: The Geolocation service failed.";
    } else {
      Bribable.initialLocation = base_location;
      contentString = "Error: Your browser doesn't support geolocation";
    }
    map.setCenter(Bribable.initialLocation);
  },

  createCircle : function() {
    var center_circle = {
      strokeColor: "#FF0000",
      strokeOpacity: 1,
      strokeWeight: 1,
      fillColor: "#FF0000",
      fillOpacity: .2,
      radius: 50,
      map: map,
      center: map.getCenter()
    };

    Bribable.circle = new google.maps.Circle(center_circle);
  },

  renderMessageMarkers: function(map) {
    var lat = map.getCenter().lat();
    var long = map.getCenter().lng();
    $.getJSON('/messages?lat=' + lat + '&long=' + long, function(messages) {
      $.each(messages, function(index, message) {
        var newLatLng = new google.maps.LatLng(message["location"][0], message["location"][1]);
        new google.maps.Marker({
          position: newLatLng,
          map: map,
          title: message["message"]
        });
      });
      Bribable.renderMessages(messages);
    });
  },

  renderMessages : function(messages) {
    var messages_div = $("ul#messages");

    $(messages_div).html("");

    $.each(messages, function(index, message) {
        if (message['s3_image_url'] == "null") {
        $(messages_div).append("<li>" + "<img src='images/trollface.png'>" + message['message'] + ' ' + jQuery.timeago(message['created_at']) + "</li>");
        }
        else {
        $(messages_div).append("<li>" + "<img src=\'"+ message['s3_image_url'] + "\'>" + message['message'] + ' ' + jQuery.timeago(message['created_at']) + "</li>");
        }
    });

    $(messages_div).effect("highlight", {}, 3000);
  },

  init : function(options) {
    var myOptions = {
      zoom: 15,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };

    map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);

    Bribable.showMessages = options.showMessages;

    // Try W3C Geolocation method (Preferred)
    if (navigator.geolocation) {
      browserSupportFlag = true;
      navigator.geolocation.getCurrentPosition(function(position) {
        Bribable.saveInitialLocation(position.coords.latitude, position.coords.longitude);
        map.setCenter(Bribable.initialLocation);
        Bribable.createCircle();
        google.maps.event.addListener(map, 'bounds_changed', function() {
          Bribable.circle.setCenter(map.getCenter());
          if (Bribable.showMessages) {
            Bribable.renderMessageMarkers(map);
          } else {
            Bribable.resetFormValues(map);
          }
        });

      }, function() {
        Bribable.handleNoGeolocation(browserSupportFlag);
      });
    } else if (google.gears) {
      // Try Google Gears Geolocation
      browserSupportFlag = true;
      var geo = google.gears.factory.create('beta.geolocation');
      geo.getCurrentPosition(function(position) {
        Bribable.initialLocation = new google.maps.LatLng(position.latitude, position.longitude);
      }, function() {
        Bribable.handleNoGeolocation(browserSupportFlag);
      });
    } else {
      // Browser doesn't support Geolocation
      browserSupportFlag = false;
      Bribable.handleNoGeolocation(browserSupportFlag);
    }
  }
}
