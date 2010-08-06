class SC2League
	#mode as in 1 for 1vs1, 2 for 2vs2, etc.
	#level as in 'Bronze', 'Silver', etc.
	attr_accessor :mode, :level, :name, :teams
	
	def initialize(mode, level, name)
		@mode = mode
		@level = level
		@name = name
		@teams = []
	end
end
