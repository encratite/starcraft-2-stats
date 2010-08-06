class SC2Division
	#mode as in 1 for 1vs1, 2 for 2vs2, etc.
	#league as in 'Bronze', 'Silver', etc.
	attr_accessor :mode, :league, :name, :teams
	
	def initialize(mode, league, name)
		@mode = mode
		@league = league
		@name = name
		@teams = []
	end
end
