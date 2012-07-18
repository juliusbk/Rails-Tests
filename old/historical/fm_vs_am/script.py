import requests as rq
import json
from fancy import fancyTable
import matplotlib.pyplot as plt
import numpy as np

run_clicks = False

run_all = False #run_click then only determines what to plot

#####   INPUT   ######
#In rails console, use Campaign.find(x).ads.first.user_ad_clusters to check if fb or am
fm_ids_zach = [23068, 23075,23077]
am_ids_zach = [23074, 23076, 23088]
zach_goal = 'clicks' # Campaign.find(23068).super_campaign.goal_type in rails c

fm_ids_loryn = [22781, 22783, 22785, 22787]
am_ids_loryn = [22782, 22784, 22786, 22788]
loryn_goal = 'connections' # Campaign.find(22781).super_campaign.goal_type 

fm_ids_joe = [22891, 22889, 22890, 22900, 22899, 22901]
am_ids_joe = [22885, 22886, 22887, 22897, 22896, 22898]
joe_goal = 'connections'

if run_clicks:
    am_ids = am_ids_zach
    fm_ids = fm_ids_zach
    goal_is_clicks = 3*[True]
else:
    am_ids = am_ids_loryn + am_ids_joe
    fm_ids = fm_ids_loryn + fm_ids_joe
    goal_is_clicks = [False]*(4+6)

if run_all:
    am_ids = am_ids_zach + am_ids_loryn
    fm_ids = fm_ids_zach + fm_ids_loryn
    goal_is_clicks = [zach_goal=='clicks']*len(am_ids_zach) +  [loryn_goal=='clicks']*len(am_ids_loryn)
###### END OF INPUT ######


##### SECRET STUFF, SKIP WHILE READING PLEASE ####
auth = ('adaptly', '$up3r$3cr3t')
baseurl = 'http://api.adaptly.com/internal_api/v1/stats/super_campaigns/campaigns/'
##### END OF SECRET STUFF :) ######

##### CODE #####
L = len(am_ids)
campaigns = dict()
for i in range(L):
    r = rq.get(baseurl+str(am_ids[i]),auth=auth).text
    campaigns[am_ids[i]] = json.loads(r)[0]['campaign_stat']
    r = rq.get(baseurl+str(fm_ids[i]),auth=auth).text
    campaigns[fm_ids[i]] = json.loads(r)[0]['campaign_stat']

am_spent = [0]*L
am_clicks = [0]*L
am_connections = [0]*L

fm_spent = [0]*L
fm_clicks = [0]*L
fm_connections = [0]*L

for i in range(L):
    am_spent[i] = campaigns[ am_ids[i] ]['spent']
    am_clicks[i] = campaigns[ am_ids[i] ]['clicks']
    am_connections[i] = campaigns[ am_ids[i] ]['connections']
    fm_spent[i] = campaigns[ fm_ids[i] ]['spent']
    fm_clicks[i] = campaigns[ fm_ids[i] ]['clicks']
    fm_connections[i] = campaigns[ fm_ids[i] ]['connections']
    
##### END OF CODE ####


##### PRINTING ####

for i in range(L):
    if goal_is_clicks[i]:
	string = 'clicks'
    else:
	string = 'fans'
    if fm_spent[i]==0:	
	a = [ ['goal='+string, 'AM', 'FM'],  ['Campaign id:', str(am_ids[i]), str(fm_ids[i])], \
	      ['Spent:', str(am_spent[i]), str(fm_spent[i])], ['Clicks:', str(am_clicks[i]), str(fm_clicks[i])], \
	       ['Clicks per spent:',  "%.3g"  % float(1.0*am_clicks[i]/am_spent[i]),  "%.3g" % 0] , \
		['Fans:', str(am_connections[i]), str(fm_connections[i])  ], \
	      ['Fans per spent:', "%.3g" % float(1.0*am_connections[i]/am_spent[i]), "%.3g" % 0 ]	]
    else:
	a = [ ['goal='+string, 'AM', 'FM'],  ['Campaign id:', str(am_ids[i]), str(fm_ids[i])], \
	      ['Spent:', str(am_spent[i]), str(fm_spent[i])], ['Clicks:', str(am_clicks[i]), str(fm_clicks[i])], \
	       ['Clicks per spent:',  "%.3g"  % float(1.0*am_clicks[i]/am_spent[i]),  "%.3g" % float(1.0*fm_clicks[i]/fm_spent[i])], \
		['Fans:', str(am_connections[i]), str(fm_connections[i])  ], \
	      ['Fans per spent:', "%.3g" % float(1.0*am_connections[i]/am_spent[i]), ("%.3g" % float(float(fm_connections[i])/fm_spent[i])) ]	]

    print fancyTable(a)
    print '\n'


##### PLOTTING ####
def norm(plot_array, other_array):
   return plot_array/(plot_array + other_array)
am_spent = np.float32( am_spent )
fm_spent = np.float32( fm_spent )
am_clicks = np.float32( am_clicks )
fm_clicks = np.float32( fm_clicks  )
am_cps = am_clicks/am_spent
fm_cps = fm_clicks/fm_spent
am_connections = np.float32(am_connections)
fm_connections = np.float32(fm_connections)
am_cops = am_connections/am_spent
fm_cops = fm_connections/fm_spent

def plotter(am_ps, fm_ps, am, fm):
    x = np.arange( L  )
    x = np.float32(x)
    am_p = plt.bar( x, norm(am_ps,fm_ps), color='#66CC66' , width = 0.3 )
    fm_p = plt.bar( x, norm(fm_ps,am_ps), color='#3666CC', bottom = norm(am_ps, fm_ps), width = 0.3  )

    x += 0.35
    am_p = plt.bar( x, norm(am,fm), color='#006600' , width = 0.4 )
    fm_p = plt.bar( x, norm(fm,am), color='#003366', bottom = norm(am, fm), width = 0.4  )
    middle = plt.plot([0, L], [0.5, 0.5], color='#ffffff')

if run_clicks:
    plotter(am_cps, fm_cps, am_clicks, fm_clicks )
    plt.title("Facebook: Blue,    Acount Managers: Green\nClicks per spent: Light,     Clicks : Dark")
else:
    plotter(am_cops, fm_cops, am_connections, fm_connections)
    plt.title("Facebook: Blue,    Acount Managers: Green\nConnections per spent: Light,     Connections : Dark")
plt.show()

