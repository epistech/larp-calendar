#!/Users/timr/.rvm/rubies/ruby-1.9.3-p385/bin/ruby

require 'Date'
require 'net/http'
require 'pp'
require 'json'

fileElement = "temp.txt"

require './documentStart'
require './documentMap'
require './documentEnd'


class CalEntry
	def new(*args)
     	print "Creating a new ", self.name, "\n"
     	oldNew(*args)
    end 
	attr_accessor(:DTSTART, :DTEND, :SUMMARY, :DESCRIPTION, :LOCATION, :LAT, :LNG)

=begin CalEntry
	- Define an object that stores the relevant parts of calendar data
=end
end


def runUpdates
	# If file has not been modified within the last hour, proceed.
	if File.mtime(fileElement) < Time.now - (60 * 60)
		File.open(fileElement, File::RDWR) {|f|
			f.flock(File::LOCK_EX)
			f.write(Time.now)
		}
		puts "File updated at #{Time.now}"
	else
		puts "File read at #{File.mtime(fileElement)}"
	end
end


def calProcessor(*filter)

=begin CalProcessor
	- Create an array to be populated with CalEntry objects.
	- When you find a BEGIN:VEVENT marker, start recording data to the next object in the array.
	- When you find a END:VEVENT marker, increment to the next object in the array.
	- # When you are done, populate HTML with array data.
	This is (should be) an Array
=end

	calendar = File.open("basic.ics", "r")
	# https://www.google.com/calendar/ical/algqb78sbithpodn64kn0udcpc%40group.calendar.google.com/public/basic.ics
	event = Array.new
	sumContinue = 0
	locContinue = 0
	descContinue = 0
	i = 0
	lineSkip = 1
	#puts "<table border=1>"

	calendar.each { |line|
		# puts line

		line.match(/BEGIN.VEVENT/) {
			# puts "New Entry to item #{i}"
			event[i] = CalEntry.new
			}

		line.match(/DTSTART:20/) {
			# puts line
			#sample.DTSTART = "20121027T140000"
			#DTSTART;TZID=America/New_York:20121027T140000

			if filter.length > 0
				# puts "actively filtering on #{filter[0]}"
				if line.match(/#{filter[0]}/)	# This line processes the filter narrowing dates.
					event[i].DTSTART = line.slice(line.index(':')+1..-1).chomp
					# puts "#{line} FILTERED FOR YES"
					lineSkip = 0
				else 
					# puts "skipping #{line}"
					lineSkip = 1
				end
			else
				puts "NO FILTER"
				event[i].DTSTART = line.slice(line.index(':')+1..-1).chomp
				lineSkip = 0
			end
			}
		
		
		if lineSkip == 0
			
			# puts "not skipping #{line}"
			line.match(/DTEND/) {
				#sample.DTEND = "20121027T170000"
				#DTEND;TZID=America/New_York:20121027T170000

				event[i].DTEND = line.slice(line.index(':')+1..-1).chomp
			}

			line.match(/SUMMARY/) {
				# Title of the Event
				event[i].SUMMARY = line.slice(8..-1).chomp
				sumContinue = 2
			}

			if sumContinue == 2 and line.match(/^[A-Z]/)
				sumContinue -= 1
			elsif sumContinue == 1 and line.match(/^\s/)
				event[i].SUMMARY += line.slice(1..-1).chomp
			else
				sumContinue = 0
			end


			line.match(/^LOCATION/) {
				#sample.LOCATION = "214 East 21st Street"
				# LOCATION:214 East 21st Street
				# http://maps.googleapis.com/maps/api/geocode/json?address=214+East+21st+Street+New+York,+NY&sensor=false

				event[i].LOCATION = line.slice(9..-1).chomp
				locContinue = 2
			}
		
			if locContinue == 2 and line.match(/^[A-Z]/)
				locContinue -= 1
			elsif locContinue == 1 and line.match(/^\s/)
				event[i].LOCATION += line.slice(1..-1).chomp
			else
				locContinue = 0
			end


			line.match(/^DESCRIPTION/) {
				#sample.DESCRIPTION = ""
				#DESCRIPTION:SVA Saturday Studio flash photography class with Richard Rothma
				# n. PHC-2649-A

				event[i].DESCRIPTION = line.slice(12..-1).chomp
				descContinue = 2
			}

			if descContinue == 2 and line.match(/^[A-Z]/)
				descContinue -= 1
			elsif descContinue == 1 and line.match(/^\s/)
				event[i].DESCRIPTION += line.slice(1..-1).chomp
			else
				descContinue = 0
			end
		end		

		line.match('END:VEVENT') {
		# Complete the object and advance increment of the "Event" Array.
			
			if lineSkip == 0
			#Process contents of a complete Calendar Object.
			#	puts "<tr>"
			#	puts "<td>#{event[i].SUMMARY}</td>"
			#	puts "<td>#{event[i].DTSTART}</td><td>#{event[i].DTEND}</td>"
			#	puts "<td>#{event[i].DESCRIPTION}</td>"
			#	puts "<td>#{event[i].LOCATION}</td>"
			#	puts "</tr>"
			# increment i only if entry has actually been skipped.

				# pp event[i]
				i += 1
				lineSkip = 1
				# pp "Entry has been recorded; advancing counter."
			else
				# puts "skipped entry."
				event.pop
			end
			# break
		}
	}
	return event
	# puts "</table>"
end

def calPrinter(cal_array)
	puts "parsed event is #{cal_array.length} entries"
	puts "today's date is #{Date.today}"
	# puts "<table border=\"1\">"
	i = 0
	export = "[
"
	
	cal_array.each_with_index { |item, i| 
	export += "	{"
# 	unless Date.strptime(cal_array[i].DTSTART[0..7], '%Y%m%d') < Date.new(2013,1,1) # Date.today or alternately, use an arbitrary selected Date
=begin
		"event_name": "True Nerd Trivia",
		"start_date": "20130424T230000Z",
		"end_date": "20130425T020000Z",
		"description": "True Nerd Trivia has moved venues yet again. Come join us at our new digs for April's Trivia event!\n\nWe are still working out the time for that evening, so stay tuned!\n\nJoin us for a night of nerdy trivia and fun prizes!\n\n\nWhere: Vlada Lounge, 2nd Floor: 331 West 51st Street, NYC\nWhen: Wednesday April 24th\nStart time: TBD\nCost: $1 Donations appreciated\n\nFoghat took home the pie last month...who will be this month's winner?\n...\nTeam size is limited to 6 players - so choose your companions wisely! If you need a team - show up and we'll find you some new friends!\n\n***\n\nFor all you newbies who have yet to experience our brand of Trivia, leave your knowledge of state capitals at home! Forget everything you learned in high school - we won't be asking you any of that stuff! Instead, our questions are all about the important things in life, such as:\n\nGeography: What is the name of the region of Middle Earth where Hobbits live?\nScience and Tech: What device will allow a Delorean to travel back in time?\nParazoology: How long would it take for you to be digested in the belly of the Sarlaac?\nSuperheroes: When Dick Grayson gets his driver's license - what car can he take for a spin?\n\nAnd much much more!!!",
		"address": "Vlada Lounge, 2nd Floor: 331 West 51st Street, NYC",
		"lat": 40.763665, 
		"lng": -73.98683900000002
=end

	export += %Q%
		"event_name":   "#{cal_array[i].SUMMARY.to_s.gsub(/\\,/, ",")}",
		"start_date":   "#{cal_array[i].DTSTART}",
		"end_date":   "#{cal_array[i].DTEND}"%

	if cal_array[i].DESCRIPTION != ""
		export += %Q%,
		"description":   "#{cal_array[i].DESCRIPTION.to_s.gsub(/\\n/, "; ").gsub(/\\,/, ",")}"%
	end

	if cal_array[i].LOCATION != ""
		tmp = JSONRetrieval(cal_array[i].LOCATION).to_s.delete('[]')
		export += %Q%,
		"address":   "#{cal_array[i].LOCATION.to_s.gsub(/\\n/, "; ").gsub(/\\,/, ",")}",
		"lat":   "#{tmp.split(/, /)[0]}",
		"lng":   "#{tmp.split(/, /)[1]}"%
end

export += "
	},
"
	}
	export += "{}]"
	temporary = File.open('larp_test.json',"w")
	temporary.write export
	temporary.close;
end

=begin
	- Retrieve JSON geocode data for a given LOCATION address.	
	# this successfully grabs a JSON file when a sufficient address is entered into the .ics file.
	# puts "http://maps.googleapis.com/maps/api/geocode/json?address=#{map}&sensor=false"
=end

def JSONRetrieval(locale)
	unless locale == ""
		# puts "Retrieving JSON(#{locale})"
		uri = URI('http://maps.googleapis.com/maps/api/geocode/json')
		params = { :address => locale, :sensor => false }
		uri.query = URI.encode_www_form(params)
		res = Net::HTTP.get_response(uri)
		if res.is_a?(Net::HTTPSuccess)
			# puts "RES.BODY: #{res.body}" 
			gJSON = JSON.parse(res.body)
			toodle = parseLatLong(gJSON) if gJSON["status"] == "OK"
			# puts toodle
		end
	end
	return toodle
end

def parseLatLong(gJSON)
	# puts "parseLatLong()"
	# gJSON = JSON.parse(rawJSON)
	# puts my_hash["results"]
	lat = gJSON["results"][0]["geometry"]["location"]["lat"]
	lng = gJSON["results"][0]["geometry"]["location"]["lng"]
	return lat, lng
	# return "Lat: #{lat}, Lng: #{lng}"
end



# runUpdates

proDate = calProcessor(2013)
calPrinter(proDate)