require 'set'

require 'nil/http'

require 'SC2Stats'

stats = SC2Stats.new('leagues')
(1..12).each do |i|
	stats.processForumPage(i)
end
