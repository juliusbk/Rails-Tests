require 'json'
##### Must be executes in rails console #####

def buildDataStructures
    def validKeyword(keyword)
	minimum_length_of_keyword = 3
	if keyword.length >= minimum_length_of_keyword
	    true
	else
	    false
	end
    end

    def campaignHasKeywords(campaign)
	if campaign.ads.length>0
	    if campaign.ads.first.keywords
		return true
	    end 
	end
	false
    end

    def combineNeighbors(arrayHash, newArray, key)
	if arrayHash == 0
	    arrayHash = Hash.new(0)
	end
	for e in newArray
	    arrayHash[e] = arrayHash[e] + 1 unless e==key
	end
	return arrayHash
    end

    keywords = Hash.new([0, 0]) #Occurences, neighbors
    campaigns = Campaign.all

    for i in 0..(campaigns.length-1)
    #for i in 0..50
	this = campaigns[i]
	puts "Running number #{i} of #{campaigns.length-1}"
	if campaignHasKeywords(this)
	    this_keywords = campaigns[i].ads.first.keywords.split(',').map{|c| c.strip()}  
	    l = this_keywords.length
	    for j in 1..l
		k = l-j
		if not validKeyword( this_keywords[k] )
		    this_keywords.delete_at(k)
		end
	    end

	    l = this_keywords.length 
	    for j in 0..(l-1)
		key = this_keywords[j]
		keywords[key] = [ keywords[key][0]+1 ,  combineNeighbors(keywords[key][1], this_keywords, key) ]
	    end
	end
    end
    keywords


end

def ds
    build_and_save('juliussmall.json')
end

def dl
    return_load('juliussmall.json')
end

def build_and_save(fname)
    keywords = buildDataStructures
    File.open(fname ,'w') do |f|
	f.write(keywords.to_json)
    end
    keywords
end

def return_load(fname)
    File.open( fname, 'r') do |f|
	JSON.load(f)
    end
end

def statistics(keywords = false, file = false)
    if not keywords
	if file
	    keywords = return_load(file)
	else
	    puts "statistics() needs keywords or file of keywords. Breaking"
	    return
	end
    end
    count = Hash.new(0)
    keywords.each do |e|
	count[e[0]] = e[1][0]
    end

    sorted = count.sort_by{ |key, value| -value } #reverse order

    for i in 0..10
        puts (i+1).to_s + ' is : ' + sorted[i][0] + '   used ' + sorted[i][1].to_s + ' times.'
    end
end

def floyd_warshall(keywords)
    def edge_cost(keywords, key1, key2)
	if keywords[key1][1].has_key?(key2)
	    100.0/keywords[key1][1][key2]
	elsif key1==key2
	    0
	else
	    keywords.length #meassure of inf
	end
    end

    def create_initial_path(keywords)
	path = Hash.new
	keywords.each do |i|
	    path[i[0]] = Hash.new
	end

	keywords.each do |i|
	    keywords.each do |j|
		path[i[0]][j[0]] = edge_cost(keywords, i[0], j[0])
	    end
	end
	path
    end

    path = create_initial_path(keywords)

    count = 0
    keywords.each do |k|
	count += 1
	puts count.to_s + ' of ' + keywords.length.to_s
	keywords.each do |i|
	    keywords.each do |j|
		path[i[0]][j[0]] = [ path[i[0]][j[0]] , path[i[0]][k[0]] + path[k[0]][j[0]] ].min
	    end
	end
    end
    return path
end

def make_simple_bucket(seeds, size, keywords)
    def seeding(seeds, keywords)
	s = []
	keywords.each do |e|
	    seeds.each do |seed|
		if e[0].downcase.include?(seed.downcase)
		    s = s+[e[0]]
		end
	    end
	end
	s
    end
    seeds = seeding(seeds, keywords)
    
    if seeds.length == 0
	puts 'No keywords found for your seed'
    else
	if seeds.length < size
	    size = seeds.length
	end
	bucketscore = Hash.new(0)

	seeds.each do |seed|
	    bucketscore[seed] = keywords.length * seeds.length
	end
	seeds.each do |seed|
	    keywords[seed][1].each do |neighbor|
		bucketscore[neighbor[0]] = bucketscore[neighbor] + 1
	    end
	end
	bucket = bucketscore.sort_by{ |key, value| -value }
	
	for i in 0..(size-1)
	    puts bucket[i][0].strip
	end
    end
end

