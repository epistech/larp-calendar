#!/Users/timr/.rvm/rubies/ruby-1.9.3-p385/bin/ruby

#home
#/Users/timrodriguez/.rvm/rubies/ruby-1.9.3-p385/bin/ruby

# work


require 'net/http'
require 'pp'

puts "Content-type: text/html\n\n"

class CalEntry
	def new(*args)
     	print "Creating a new ", self.name, "\n"
     	oldNew(*args)
    end 
	attr_accessor(:DTSTART, :DTEND, :SUMMARY, :DESCRIPTION, :LOCATION)

=begin CalEntry
	- Define an object that stores the relevant parts of calendar data
=end
end




def calProcessor(*filter)

=begin CalProcessor
	puts "Arguments: "
	if filter.length > 0
		puts filter
	else
		puts "none"
	end

	- Create an array to be populated with CalEntry objects.
	- When you find a BEGIN:VEVENT marker, start recording data to the next object in the array.
	- When you find a END:VEVENT marker, increment to the next object in the array.
	- When you are done, populate HTML with array data.
=end

	calendar = File.open("nerdnyc.ics", "r")
	# https://www.google.com/calendar/ical/algqb78sbithpodn64kn0udcpc%40group.calendar.google.com/public/basic.ics
	event = Array.new
	sumContinue = 0
	locContinue = 0
	descContinue = 0
	i = 0

	calendar.each { |line|
		# puts line
		line.match(/BEGIN.VEVENT/) {
			event[i] = CalEntry.new
			}

		line.match(/DTSTART:20/) {
		#sample.DTSTART = "20121027T140000"
		#DTSTART;TZID=America/New_York:20121027T140000

			if filter.length > 0
				if line.match(/#{filter[0]}/)	# This line is just a filter for 2013 dates, otherwise unimportant.
					event[i].DTSTART = line.slice(line.index(':')+1..-1).chomp
				end
			else
				event[i].DTSTART = line.slice(line.index(':')+1..-1).chomp
			end
			}
		
		line.match(/DTEND/) {

		#sample.DTEND = "20121027T170000"
		#DTEND;TZID=America/New_York:20121027T170000

			if event[i].DTSTART		# This and others are strictly limited to following the filter on .DTSTART
				event[i].DTEND = line.slice(line.index(':')+1..-1).chomp
			end
			}

		line.match(/SUMMARY/) {
	
		# Title of the Event
			if event[i].DTSTART
				event[i].SUMMARY = line.slice(8..-1).chomp
				sumContinue = 2
			end
			}
		if line.match(/^[A-Z]/) and sumContinue == 2
			sumContinue -= 1
		elsif line.match(/^\s/) and sumContinue == 1
			event[i].SUMMARY += line.slice(1..-1).chomp
		else
			sumContinue = 0
		end


		line.match(/^LOCATION/) {

		#sample.LOCATION = "214 East 21st Street"
		# LOCATION:214 East 21st Street
		# http://maps.googleapis.com/maps/api/geocode/json?address=214+East+21st+Street+New+York,+NY&sensor=false

			if event[i].DTSTART
				event[i].LOCATION = line.slice(9..-1).chomp
				locContinue = 2
			end
			}
		
		if line.match(/^[A-Z]/) and locContinue == 2
			locContinue -= 1
		elsif line.match(/^\s/) and locContinue == 1
			event[i].LOCATION += line.slice(1..-1).chomp
		else
			locContinue = 0
		end


		line.match(/^DESCRIPTION/) {

		#sample.DESCRIPTION = ""
		#DESCRIPTION:SVA Saturday Studio flash photography class with Richard Rothma
		# n. PHC-2649-A

			if event[i].DTSTART
				event[i].DESCRIPTION = line.slice(12..-1).chomp
				descContinue = 2
			end
			}

		if line.match(/^[A-Z]/) and descContinue == 2
			descContinue -= 1
		elsif line.match(/^\s/) and descContinue == 1
			event[i].DESCRIPTION += line.slice(1..-1).chomp
		else
			descContinue = 0
		end

		line.match('END:VEVENT') {
		# Complete the object and advance increment of the "Event" Array.

			if event[i].DTSTART
			#Process contents of a complete Calendar Object.
				puts "Announcing: #{event[i].SUMMARY}"
				puts "from #{event[i].DTSTART} to #{event[i].DTEND}"
				puts "what: #{event[i].DESCRIPTION}"
				puts "where: #{event[i].LOCATION}"
				puts
				i += 1
			end
			# break
		}
	}
end

=begin
	- Retrieve JSON geocode data for a given LOCATION address.	
	# this successfully grabs a JSON file when a sufficient address is entered into the .ics file.
	# puts "http://maps.googleapis.com/maps/api/geocode/json?address=#{map}&sensor=false"

class JSONRetrieval
	uri = URI('http://maps.googleapis.com/maps/api/geocode/json')
	params = { :address => sample.LOCATION, :sensor => false }
	uri.query = URI.encode_www_form(params)
	res = Net::HTTP.get_response(uri)
	puts res.body if res.is_a?(Net::HTTPSuccess)
end
=end

=begin
	- Parsing JSON for use.
require 'json'
require 'pp'
json = File.read('employees.json')
empls = JSON.parse(json)

pp empls

empls["Human Resources"].each {|person|
puts person}

=end



puts calProcessor('2013')
