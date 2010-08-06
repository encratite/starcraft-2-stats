require 'division'

def getPercentage(value, containerOrSize)
	if containerOrSize.class == Array
		size = containerOrSize.size
	else
		size = containerOrSize
	end
	return sprintf('%.2f%%', value.to_f / size * 100.0)
end

def printPercentage(description, value, containerOrSize)
	percentage = getPercentage(value, containerOrSize)
	puts "    #{description}: #{percentage}"
end

def printUnit(description, &block)
	puts description
	block.call
	puts ''
end

modeCounter = {}
(1..4).each {|i| modeCounter[i] = 0}

leagueCounter = {}
leagues = ['Bronze', 'Silver', 'Gold', 'Platinum', 'Diamond']
leagues.each {|league| leagueCounter[league] = 0}

raceCounter = {}
races = ['Terran', 'Zerg', 'Protoss', 'Random']
races.each {|race| raceCounter[race] = 0}
playerCount = 0

#for 1vs1
leagueRaceCounter = {}
leagues.each do |league|
	currentCounter = {}
	races.each do |race|
		currentCounter[race] = 0
	end
	leagueRaceCounter[league] = currentCounter
end

divisions = loadDivisions

puts "Loaded #{divisions.size} divisions"

divisions.each do |division|
	modeCounter[division.mode] += 1
	league = division.league.gsub('Random ', '')
	leagueCounter[league] += 1
	division.teams.each do |team|
		team.players.each do |player|
			race = player.race
			raceCounter[race] += 1
			playerCount += 1
			if division.mode == 1
				leagueRaceCounter[league][race] += 1
			end
		end
	end
end

printUnit('Distribution of modes:') do
	modeCounter.each do |key, value|
		printPercentage("#{key}vs#{key}", value, divisions)
	end
end

printUnit('Distribution of leagues:') do
	leagueCounter.each do |key, value|
		printPercentage(key, value, divisions)
	end
end

printUnit('Distribution of races:') do
	raceCounter.each do |key, value|
		printPercentage(key, value, playerCount)
	end
end

leagues.each do |league|
	printUnit("Distribution of races within the 1vs1 #{league} league:") do
		totalCount = 0
		races.each do |race|
			totalCount += leagueRaceCounter[league][race]
		end
		races.each do |race|
			value = leagueRaceCounter[league][race]
			printPercentage(race, value, totalCount)
		end
	end
end
