require 'division'

def getPercentage(value, divisions)
	return sprintf('%.2f%%', value.to_f / divisions.size * 100.0)
end

modeCounter = {}
(1..4).each {|i| modeCounter[i] = 0}

leagueCounter = {}
leagues = ['Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond']
randomLeagues = []
leagues.each do |league|
	randomLeagues << "Random #{league}"
end
leagues = leagues + randomLeagues
leagues.each {|league| leagueCounter[league] = 0}

divisions = loadDivisions

puts "Loaded #{divisions.size} divisions"

divisions.each do |division|
	modeCounter[division.mode] += 1
	leagueCounter[division.league] += 1
end

puts 'Distribution of modes:'
modeCounter.each do |key, value|
	percentage = getPercentage(value, divisions)
	puts "  #{key}vs#{key}: #{percentage}"
end

puts 'Distribution of leagues:'
leagueCounter.each do |key, value|
	percentage = getPercentage(value, divisions)
	puts "  #{key}: #{percentage}"
end
