require 'set'

require 'nil/http'

require 'Configuration'
require 'SC2Stats'

stats = SC2Stats.new(Configuration::OutputDirectory)
(1..12).each do |i|
	stats.processForumPage(i)
end
