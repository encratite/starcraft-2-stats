#http://eu.battle.net/sc2/en/profile/875156/1/MightyMike/ladder/3981#current-rank
#http://eu.battle.net/sc2/en/profile/175968/1/Ouroboros/ladder/4062#current-rank

require 'set'

require 'nil/http'

class SC2Stats
	def initialize
		cookies = {
			'perm' => 1,
			'int-SC2' => 1
		}
		@server = Nil::HTTP.new('eu.battle.net', cookies)
		@profilePaths = Set.new
		@leaguePaths = Set.new
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
			if @profilePaths.include?(path)
				next
			end
			@profilePaths.add(path)
			data = getPath(path)
			processProfile(data)
		end
	end
	
	def processProfile(input)
		pattern = /"(.+?)#current-rank"/
		input.scan(pattern) do |match|
			leaguePath = match[0]
			if @leaguePaths.include?(leaguePath)
				next
			end
			@leaguePaths.add(leaguePath)
			data = getPath(leaguePath)
			processLeague(data)
		end
	end
	
	def processLeague(input)
		leaguePattern = /\/ladder\/(\d+)'\)[\s\S]+?(\d)v\d (.+?) <span>[\s\S]+?Division (.+?) <span>/
		match = input.match(leaguePattern)
		if match == nil
			puts "Failed to match league"
			return
		end
		id = match[1].to_i
		mode = match[2].to_i
		league = match[3]
		division = match[4]
		puts "#{id}: #{mode}, #{league}, #{division}"
		
		pattern = /(<div id="player-info-(\d+)" style="display: none">[\s\S]+?<div class="tooltip-title">([A-Za-z0-9]+?)<\/div>[\s\S]+?<strong>Favorite Race:<\/strong> ([A-Za-z]+)[\s\S]+?)+?<td class="align-center">(\d+)<\/td>[\s\S]+?<td class="align-center">(\d+)<\/td>[\s\S]+?<td class="align-center">(\d+)<\/td>/
		input.scan(pattern) do |match|
			points = match[-3].to_i
			wins = match[-2].to_i
			losses = match[-1].to_i
			puts "#{points} points, #{wins} wins, #{losses} losses"
			offset = 0
			while offset < match.size - 3
				id = match[offset + 1].to_i
				name = match[offset + 2]
				race = match[offset + 3]
				offset += 1 + 3
				puts "#{id}: #{name}, #{race}"
			end
		end
	end
end

stats = SC2Stats.new
stats.processForumPage(1)
