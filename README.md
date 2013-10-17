Global Larp Calendar
=============

At this time, the calendar consists of an "integration" with a Google Calendar account. Entries must be added to the calendar, but then are automatically added to this larpcalendar app via the updateJSON.rb ruby script (which is generally called via an asynchronous XHR request, triggered by loading the page at a maximum of once/hour so as not to overload gmaps request. 

Ruby application pulls down and parses a Google Calendar .ICS file into a locally stored JSON file in order to redisplay content.

Uses GoogleMaps API calls to display markers on a map.

Ruby/JSRender scripts then do filtering on a cached JSON file.

## Features
- A virtually _unlimited_ repository of larp calendaring data, stored in a GCal, and downloaded/reorganized in a local JSON file.
- First start of real location awareness. Awesome.

## Changelog
Nothing explicit here so far... Still working in an pre-alpha status.

* Added meta tag/CSS code to make the interrface.html look a little nicer, and work on devices.
* Started documenting all of the different moving parts to clean up the horribly fractured codebase.

## Display engine
* interface.html
* jsrender.js
* jquery-1.9.1.min.js

## Parsing Engine
* cards.rb — This is an extraction (improvement?) to the all-in-one index.rb script
* documentEnd.rb — contains a final closing tags for HTML display. _deprecated?_
* documentMap.rb — writes a map canvas div _deprecated?_
* documentStart.rb — contains a html head for display_deprecated?_
* index.rb — contains a lot of the parsing code
* temp.txt — contains a timestamp marking the last-update so that we don't go crazy with scraping the Google Calendar.
* updateJSON.rb — This is a front-end called script that tests against temp.txt to scrape the .ICS file and turn it into a cached JSON file.


## Development files
* architecture.graffle — This file contains the ideal final structure of the app. It's not quite complete, but it's the core idea of what the app should eventually look like.
* basic.ics — overwhelmingly complete .ICS file, might be useful for testing.
* larpcal.json — contains a sample of differently formatted JSON calendar elements for testing.
* larp_test.ics — raw ICS file for testing ICS scraping.
* nerdnyc.ics — raw ICS file has been used for testing the parsing engine.
* parseLatLng.rb — extracts lat/lng values from a JSON file. — _deprecated?_

## TODO
- Investigate what the difference in lat/long values is for a given location radius.
- Better understand the implementation location-awareness on the front-end.

## Wish List
- Sorted 
- Defined regions for core area sorts, instead of just date.
- Web-based location awareness that triggers this location sorting.

## Notes for future development

**Parsing engine**

* Script that parsing ICS into JSON needs to write human-readable dates out of the timestamps
* Description field needs a hashtag filter device at the end that separates it into a JSON array.

**Display engine**

* Move interface.html -> index.html
* calendarDesktopTemplate needs to look nicer 

**FUTURE**

* Add a user-submission form to plug into GCal