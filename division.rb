require 'nil/file'

require 'SC2Division'
require 'SC2Team'
require 'SC2Player'

require 'Configuration'

def loadDivisions
	output = []
	entries = Nil.readDirectory(Configuration::OutputDirectory)
	entries.each do |entry|
		data = Nil.readFile(entry.path)
		division = Marshal.load(data)
		output << division
	end
	return output
end
