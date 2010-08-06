class SC2Team
	attr_accessor :score, :wins, :losses, :players
	
	def initialize(score, wins, losses)
		@score = score
		@wins = wins
		@losses = losses
		@players = []
	end
end
