# Use as:
#   $ python network_metrics_onodo.py < game-of-thrones-edges.txt
#
# Dependencies:
# - pip install python-igraph
#
# A nice introduction to igraph: http://igraph.org/python/doc/tutorial/tutorial.html

import igraph
import sys
from igraph import Graph as G

# Set to False to avoid displaying messages about the execution in the shell
verbose = False

# PARAMETERS - DEFAULT VALUES
# Set to True for the network to be considered as directed.
directed = False		
# The metrics to be computed. By default, all are included (mdrbck).
#   m: clusters (Louvain Modularity)
#   d: degree
#   r: relevance
#   b: betweenness
#   c:closeness
#   k: coreness (k-index)
#   l: distance (path length) from base_node
metrics = 'mdrbckl'
# Set to 'False' for ignoring edges direction when computing betweenness in a directed network.
betweenness_directed = True
# Set to 'IN' or 'OUT' to consider the length of incoming or outgoing paths (respectively) when
# computing closeness in a directed network.
closeness_mode = 'ALL'
# Set to 'IN' or 'OUT' to compute in-coreness or out-coreness (respectively) in a directed network.
# By default, edge direction will not be considered when computing coreness in a directed network.
coreness_mode = 'ALL'
# Node for which the distances from all other nodes will be computed (in case "l" is included in
# parameter "metrics"). Can be node label or id. By default it is the first node appearing in the
# network file (node 0)
base_node = 0

# TODO: Support overriding of settings from caller. Disabled for now.
# Overwrite parameter values, when specified in the query
# directed_values = ['directed', 'dir', 'd', 'true', 'yes', 'y']
# undirected_values = ['false', 'no', 'n', 'undirected', 'un']
# if request.query.metrics: metrics = request.query.metrics
# if request.query.directed.lower() in directed_values: directed = True 
# if request.query.b_directed.lower() in undirected_values: betweenness_directed = False
# if request.query.c_mode: closeness_mode = request.query.c_mode.upper()
# if request.query.k_mode: coreness_mode = request.query.k_mode.upper()
# if request.query.base_node: base_node = request.query.base_node

# Read and parse the network
g = G.Read(sys.stdin, 'ncol', directed = directed)
if verbose:
	print 'read network. %d nodes and %d edges' %(g.vcount(), g.ecount())

# Calculate metrics, and generate output header
output = 'node'

if metrics.find('m') >= 0:	
	if directed: 
		#create an undirected copy of the graph for computing thr Louvain method	
		g_und = g.copy()		
		g_und.to_undirected(mode="collapse")	
	else:
		g_und = g
	clustering = g_und.community_multilevel()
	node_clusters = {}
	for i in range(len(clustering)):
		for n in clustering[i]:
			node_clusters[n] = i+1
	output += ',cluster'

if metrics.find('d') >= 0:
	if directed:
		indegree = g.indegree()
		output += ',indegree'
		outdegree = g.outdegree()
		output += ',outdegree'
	else:	
		degree = g.degree()		
		output += ',degree'

if metrics.find('r') >= 0:	
	output += ',relevance'
	if directed:
		pagerank = g.pagerank()
	else:	
		eigenvector = g.eigenvector_centrality()		

if metrics.find('b') >= 0:
	betweenness = g.betweenness(directed=directed and betweenness_directed)		
	output += ',betweenness'

if metrics.find('c') >= 0:
	closeness = g.closeness(mode=closeness_mode)		
	output += ',closeness'

if metrics.find('k') >= 0:
	coreness = g.coreness(mode=coreness_mode)		
	output += ',coreness'

if metrics.find('l') >= 0:
	shortest_paths = g.get_shortest_paths(base_node, to=None, weights=None, mode='ALL', output="vpath")	
	output += ',distance_from_node' 

output += '\n'

# Output calculated metric for each node
for v in range(g.vcount()):
	output += '"' + g.vs[v]['name'] + '"'
	if 'm' in metrics: 
		output += ',' + str(node_clusters[v])	
	if 'd' in metrics: 
		if directed:
			output += ',' + str(indegree[v])
			output += ',' + str(outdegree[v])
		else:
			output += ',' + str(degree[v])
	if 'r' in metrics: 
		if directed:
			output += ',' + str(pagerank[v])
		else:
			output += ',' + str(eigenvector[v])
	if 'b' in metrics: 
		output += ',' + str(betweenness[v])
	if 'c' in metrics: 
		output += ',' + str(closeness[v])
	if 'k' in metrics: 
		output += ',' + str(coreness[v])
	if 'l' in metrics: 
		output += ',' + str(len(shortest_paths[v])-1) 
	output += '\n'

# Show results on screen
print output
