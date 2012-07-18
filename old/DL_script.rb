##### Functions to be run in Rails console #####
##### Do 'bundle exec rails c' first       #####
##### then load and execute functions      #####

#  ---------------  Begin Parameters  -------------#
def run
    puts " ---- Zach's 'Petitie Oekraine' Data: -----"
    fb_reach = [6516500, 3023680, 7921020]
    am_reach = [6563120, 3098720, 7799720]

    id1 = [23068, 23075, 23077]
    id2 = [23074, 23076, 23088] 
    
    puts "Loryn's Data -------"
    fb_reach = [12408040, 12408040, 6686500, 10681780]
    am_reach = [12626540, 12626540, 7057180, 11165680]

    id1 = [22781, 22783, 22785, 22787]
    id2 = [22782, 22784, 22786, 22788]    
  
    iterate_arrays(id1, id2, am_reach, fb_reach)
end
#  ---------------  End Parameters  -------------#


#  ---------------  Begin Code  -------------#
def iterate_arrays(id1_campaign, id2_campaign, am_reach, fb_reach)
    n = id1_campaign.length
    if ( n != id2_campaign.length )
	raise "The compare lists must have equal lengths"
    end
    print_results = []*n

    for i in 0..(n-1)
	print_results[i] = calculate_and_print( id1_campaign[i],  id2_campaign[i], am_reach[i], fb_reach[i] )
    end

    for i in 0..(n-1)
	puts " ---------  Result of Comparison ----------- \n \n"
	puts "   Run :   id=" + id1_campaign[i].to_s() + "   vs.   id=" + id2_campaign[i].to_s()+"\n\n"
	puts print_results[i]
    end

    true
end

def calculate_and_print(id1_campaign, id2_campaign, am_reach, fb_reach)
       
    ### Download and Identify Data ###
    value = Campaign.find(id1_campaign).super_campaign.goal_type
    
    if ( value == Campaign.find(id2_campaign).super_campaign.goal_type )
	puts "\nWarning: The campaigns #{id1_campaign} and #{id2_campaign} do not have the same goal type!"
    end
  
    ad_ids = Campaign.where( :id => id1_campaign).first.ads.map(&:id)
    id1_values = eval('Stat.where( :ad_id => ad_ids  ).map{|c| c.'+value+'}')
    id1_spent = Ad.where( :id => ad_ids ).map{ |c| c.spent }.inject(:+)
    id1_is_AM = Ad.find( ad_ids.first ).keywords != nil

    ad_ids = Campaign.where( :id => id2_campaign).first.ads.map(&:id)
    id2_values = eval('Stat.where( :ad_id => ad_ids  ).map{|c| c.'+value+'}')
    id2_spent = Ad.where( :id => ad_ids ).map{ |c| c.spent }.inject(:+)
    id2_is_AM = Ad.find( ad_ids.first ).keywords != nil

    id1_is = FB_or_AM(id1_is_AM)
    id2_is = FB_or_AM(id2_is_AM)

    if (id1_is_AM == id2_is_AM)
	puts "\nWarning: Both ids correspond to buckets created by "+id1_is
    end

    ### Process ###
    id1_result = id1_values.inject(:+)
    id1_result *=  weight_factor(id1_is_AM, am_reach, fb_reach)
    
    id2_result = id2_values.inject(:+)
    id2_result *=  weight_factor(id2_is_AM, am_reach, fb_reach)

    id1_result_per_cost = id1_result/(1.0 * id1_spent)
    id2_result_per_cost = id2_result/(1.0 * id2_spent)

    ### Save Print ###
    p = "                  "+id1_is+"                            "+id2_is+"\n"
    p += " Total Score:      "+id1_result.to_s()+"                            "+id2_result.to_s()+"\n"
    p += " Score Per Cost:   "+id1_result_per_cost.to_s()+"        "+id2_result_per_cost.to_s()+"\n"

    p += "\n -----------------------"+value+"----------------------"+"\n\n"

    p
end


def FB_or_AM(is_AM)
    if (is_AM)
	'AM'
    else
	'FM'
    end
end

def weight_factor(is_AM, am_reach, fb_reach)
    if (is_AM)
	(am_reach + fb_reach)/(2.0*am_reach)
    else
	(am_reach + fb_reach)/(2.0*fb_reach)
    end

    1
end

