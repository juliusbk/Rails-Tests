def buildDataStructures
  spent = Hash.new(0)
  cpc = Hash.new(0)
  cpi = Hash.new(0)

  campaigns = Campaign.all
  campaigns.each do |campaign|
    keyword_string = campaign.ads.first.keywords.strip()
    if keyword_string.length > 0
      spent[keyword_string] += spent(campaign)
      cpc[keyword_string] += cpc(campaign)
      cpi[keyword_string] += cpi(campaign)
    end
  end

  
end
