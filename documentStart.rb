def documentStart(*markers)
	puts %q[Content-type: text/html
	
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8" />
	<title>Untitled</title>
<script type="text/javascript" src="jquery-1.9.1.min.js"></script>
<script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?key=AIzaSyBn_ZO__dCD3xWXW7S-B8FrwfWqn8635a4&sensor=false"></script>
</head>
<body onload="initialize()">

<script>
	  var geocoder;
	  var map;

	  function initialize() {
		geocoder = new google.maps.Geocoder();
		var latlng = new google.maps.LatLng(-34.397, 150.644);
		var mapOptions = {
		  zoom: 8,
		  center: latlng,
		  mapTypeId: google.maps.MapTypeId.ROADMAP
		}
		map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);
	codeAddress(40.234232,-25.342);
	
]
puts markers


puts %q[	  }


	function codeAddress(calendarAddy) {
		geocoder.geocode( { 'address': calendarAddy}, function(results, status) {
		  if (status == google.maps.GeocoderStatus.OK) {
			map.setCenter(results[0].geometry.location);
			var marker = new google.maps.Marker({
				map: map,
				position: results[0].geometry.location
			});
		 } else {
			alert('Geocode was not successful for the following reason: ' + status);
		 } 
		});
		}
</script>]

end
