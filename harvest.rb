require 'set'

require 'nil/http'

require 'SC2Stats'

stats = SC2Stats.new('leagues')
threads = []
(1..12).each do |i|
	thread = Thread.new { stats.processForumPage(i) }
	threads << thread
end

threads.each do |thread|
	thread.join
end
