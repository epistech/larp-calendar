#!/Users/timrodriguez/.rvm/rubies/ruby-1.9.3-p385/bin/ruby

require 'Date'
fileElement = "temp.txt"

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