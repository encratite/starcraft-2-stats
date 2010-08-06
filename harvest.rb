require 'set'

require 'nil/http'

require 'SC2Stats

stats = SC2Stats.new('leagues')
stats.processForumPage(1)
