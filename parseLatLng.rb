#!/Users/timr/.rvm/rubies/ruby-1.9.3-p385/bin/ruby

require 'json'
require 'pp'
json = File.read('sample_loc.json')
map = JSON.parse(json)


# pp map

map["results"][0].each {|person| 

if person.include?("geometry")
	pp person[1]["location"]["lat"]
	pp person[1]["location"]["lng"]
end

}

# ["results:geometry"]


#  
