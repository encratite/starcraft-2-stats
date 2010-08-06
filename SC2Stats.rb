require 'thread'

require 'nil/file'

require 'SC2Division'
require 'SC2Team'
require 'SC2Player'

class SC2Stats
	def initialize(outputDirectory)
		cookies = {
			'perm' => 1,
			'int-SC2' => 1
		}
		@outputDirectory = outputDirectory
		@server = Nil::HTTP.new('eu.battle.net', cookies)
		@profilePaths = Set.new
		@mutex = Mutex.new
	end
	
	def getPath(path)
		puts "Downloading #{path}"
		output = @server.get(path)
		if output == nil
			raise "Failed ot retrieve #{path}"
		end
		return output
	end
	
	def getPage(page)
		#multiplayer forums
		path = "/sc2/en/forum/11818/?page=#{page}"
		data = getPath(path)
	end
	
	def processForumPage(page)
		data = getPage(page)
		pattern = /<a href="\.\.\/topic\/(\d+)/
		ids = Set.new
		data.scan(pattern) do |match|
			id = match[0]
			ids.add(id)
		end
		ids.each do |id|
			path = "/sc2/en/forum/topic/#{id}"
			data = getPath(path)
			processPosts(data)
		end
	end
	
	def processPosts(input)
		pattern = /<div class="avatar-interior">[\s\S]+?<a href="(.+?)">[\s\S]+?<\/a>[\s\S]+?<\/div>/
		paths = Set.new
		input.scan(pattern) do |match|
			path = match[0]
			@mutex.synchronize do
				if @profilePaths.include?(path)
					puts "Skipping profile #{path} because it has already been processed"
					next
				end
				@profilePaths.add(path)
			end
			data = getPath(path)
			processProfile(data)
		end
	end
	
	def processProfile(input)
		pattern = /"(.+?ladder\/(\d+))#current-rank"/
		input.scan(pattern) do |match|
			divisionPath = match[0]
			id = match[1]
			outputPath = Nil.joinPaths(@outputDirectory, id)
			if File.exists?(outputPath)
				puts "League data file #{outputPath} already exists"
				next
			end
			data = getPath(divisionPath)
			division = processDivision(data)
			serialised = Marshal.dump(division)
			Nil.writeFile(outputPath, serialised)
		end
	end
	
	def processDivision(input)
		leaguePattern = /\/ladder\/(\d+)'\)[\s\S]+?(\d)v\d (.+?) <span>[\s\S]+?Division (.+?) <span>/
		match = input.match(leaguePattern)
		if match == nil
			puts "Failed to match league"
			return
		end
		id = match[1].to_i
		mode = match[2].to_i
		league = match[3]
		name = match[4]
		puts "Division #{id}: #{mode}, #{league}, #{name}"
		
		division = SC2Division.new(mode, league, name)
		
		pattern = /(<div id="player-info-(\d+)" style="display: none">[\s\S]+?<div class="tooltip-title">([A-Za-z0-9]+?)<\/div>[\s\S]+?<strong>Favorite Race:<\/strong> ([A-Za-z]+)[\s\S]+?)+?<td class="align-center">(\d+)<\/td>[\s\S]+?<td class="align-center">(\d+)<\/td>[\s\S]+?<td class="align-center">(\d+)<\/td>/
		input.scan(pattern) do |match|
			points = match[-3].to_i
			wins = match[-2].to_i
			losses = match[-1].to_i
			puts "#{points} points, #{wins} wins, #{losses} losses"
			offset = 0
			team = SC2Team.new(points, wins, losses)
			while offset < match.size - 3
				id = match[offset + 1].to_i
				name = match[offset + 2]
				race = match[offset + 3]
				offset += 1 + 3
				puts "#{id}: #{name}, #{race}"
				player = SC2Player.new(id, name, race)
				team.players << player
			end
			division.teams << team
		end
		
		return division
	end
end
