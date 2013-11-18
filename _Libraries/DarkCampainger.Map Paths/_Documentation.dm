#if 0

/* *********************************************************************


                    M"""""`'"""`YM
                    M  mm.  mm.  M
                    M  MMM  MMM  M .d8888b. 88d888b.
                    M  MMM  MMM  M 88'  `88 88'  `88
                    M  MMM  MMM  M 88.  .88 88.  .88
                    M  MMM  MMM  M `88888P8 88Y888P'
                    MMMMMMMMMMMMMM          88
                                            dP
             MM"""""""`YM            dP   dP
             MM  mmmmm  M            88   88
             M'        .M .d8888b. d8888P 88d888b. .d8888b.
             MM  MMMMMMMM 88'  `88   88   88'  `88 Y8ooooo.
             MM  MMMMMMMM 88.  .88   88   88    88       88
             MM  MMMMMMMM `88888P8   dP   dP    dP `88888P'
             MMMMMMMMMMMM

                Created by David "DarkCampainger" Braun

            Released under the Unlicense (see _Unlicense.dm)

                   Version 1.0 - September 22, 2012

            Please see 'Demo/Demo.dm' for the example usage

*///////////////////////////////////////////////////////////////////////


## Summary
#######################

"' The Map Paths library is designed to allow you to quickly map out
"'   paths for your NPCs to follow, by simply placing arrows to direct
"'   them where to go. When the world is started, the library traces out
"'   these paths and stores the result in a graph for easy access.

## Basic Usage
#######################

"' For basic usage, see the demo. The following is a brief summary:
"'
"' Once you've included the library in your project, first you need to
"'   make your NPCs inherit from the /MapPaths/Pather type so that they
"'   can interact with the paths.
"' Next, you need to create an AI loop for your NPC that calls the
"'   currentNode's [execute()] proc, and changes to the next node when
"'   it reaches the current node (execute() returns TRUE)
"' Finally, if necessary, override the [nodeStep()] proc to work with
"'   your movement system.
"'
"' Once your NPCs are set up, all you have to do is place some of the
"'   path nodes (/MapPaths/Node/[subset]/[direction]) on the map and
"'   place your NPCs on the paths. The different subsets allow you to
"'   have overlapping paths that don't interfere with one another.

## Custom Path Nodes
#######################

"' You can create your own path node types to trigger special behaviors
"'   on your NPCs, such as to look around. See the demo for an example.
"'
"' First, define your custom node type under /MapPaths/Node/_base. You
"'   can put them under a forth parent type for organization. Most
"'   custom behavior can be created by simply overriding [execute()].
"'   You should also set a custom icon so you don't need to alter the
"'   library's path node icon file.
"' Next, use the [MP_ADD_SUBSET()] macro to generate subsets for your
"'   node by passing it the path to your custom node (relative to the
"'   /MapPaths/Node/_base/ type, not starting with a slash) and the
"'   icon_state for your node (which will have the subsets prefixed to
"'   it: Green_[state], Blue_[state], Red_[state], ect)
"'
"' Now you can access your node just like any other, for any subset.

## Reference
#######################

/MapPaths (/datum)

"'   This is the container type for the library. All other types and
"'     global procs are defined under it. You can access an instance
"'     of it via the global variable [MapPaths], for example:
"'     [MapPaths.getNearestGraphNode()]
"'
//   Variables:
"'
::      Graphs (list)
"'         A list of all of the /MapPaths/Graph datums
"'
//   Procedures:
"'
::      getNearestGraphNode(atom/A, subset = 0, maxDistance = 32)
"'
"[         A:            Atom to search near
"[         subset:       Subset to limit to, 0 for any
"[         maxDistance:  Maximum distance to search
"'
"[         Returns:      Nearest path node found, or null
"'
"'         This procedure searches all of the graphs for the one with
"'           the node nearest to the given atom. Note that the atom
"'           may already be 'past' the node returned in terms of path
"'           order, and you should use [Node.isApproaching()] to test
"'           if you should skip to the next node. See demo for example.
"'
::      getNearestSegmentPoint(atom/A, MapPaths/Node/nodeA,
"[                             MapPaths/Node/nodeB)
"'
"[         A:            Atom to search near
"[         nodeA:        First node
"[         nodeB:        Second node
"'
"[         Returns:      The turf along the line between the two nodes
"[                       that is closest to the atom
"'
"'         Given two connected nodes and an atom, this procedure finds
"'           the turf along the line between the two nodes that is
"'           closest to the atom. Use this to find a 'reconnection'
"'           point when an NPC walks off the path and you don't want
"'           them to walk straight to the next node.

/MapPaths/Graph (/datum)

"'   A graph is a collection of nodes, and represents one
"'     complete path 'circuit'.
"'
//   Variables:
"'
::      nodes (list)
"'         A list of all of the /MapPaths/Node datums in this graph
"'
::      pathers (list)
"'         A list of all of the /MapPaths/Pather instances in this graph
"'
::      subset (mixed)
"'         Which subset the graph is a part of
"'
//   Procedures:
"'
::      getNearestNode(atom/A, maxDistance = null)
"'
"[         A:            Atom to search near
"[         maxDistance:  Maximum distance to search
"'
"[         Returns:      Nearest path node found, or null
"'
"'         This procedure searches all of the nodes in the graph for
"'           the node nearest to the given atom. Note that the atom
"'           may already be 'past' the node returned in terms of path
"'           order, and you should use [Node.isApproaching()] to test
"'           if you should skip to the next node. See demo for example.
"'

/MapPaths/Node (/obj)

"'   A node one point in a path graph, and can be placed on the map.
"'
//   Variables:
"'
::      enterDir (number)
"'         A directional flag representing which direction a pather may
"'           be moving when they enter this node. 0 for any.
"'
::      exitDir (list)
"'         A directional flag representing which direction the pather
"'           exits this node from. 0 for same direction as entered.
"'           Set to -1 for the reverse of the direction entered from.
"'
::      subset (mixed)
"'         Which subset the node is a part of. Nodes will only connect
"'           with other nodes that share the same subset.
"'         The default subsets are:
"'           'Blue', 'Green', 'Purple', 'Red', 'Yellow' (case-sensitive)
"'
::      graph (/MapPaths/Graph)
"'         The graph that this node is a part of
"'
//   Procedures:
"'
::      execute(MapPaths/Pather/M)
"'
"[         M:            Pather to execute on
"'
"[         Returns:      True if pather has reached node, else false
"'
"'         This procedure should be called to move pathers along the
"'           path. By default, all it does is call the pather's
"'           [nodeStep()] proc, which handles the movement and return
"'           value. This can be overriden to implement custom behavior
"'           for nodes.
"'
::      getNext(cycle=0)
::      getPrev(cycle=0)
"'
"[         cycle:        Index of which next/prev node to pick when
"[                       there are multiple options. 0 picks randomly.
"'
"[         Returns:      The next/prev node in the path graph.
"'
"'         Use this procedure to get the next node in the path for your
"'           pathers. If non-zero, the 'cycle' argument is used as the
"'           index of the desired node (if it's greater than the number
"'           of nodes to choose from, it's wrapped around with modulo).
"'           This can be used to allow your pathers to alternate between
"'           choices, or to make them always make the same choice. Use
"'           [getNextCount()] to see if there are multiple choices.
"'
::      getNextList()
::      getPrevList()
"'
"[         Returns:      A /list object containing all of the next/prev
"[                       nodes. Always returns a list.
"'
"'         Use this procedure to get the list of possible next/prev
"'           nodes to handle yourself. The list itself is safe to alter
"'           without changing the path, but not the nodes inside it.
"'
::      getNextCount()
::      getPrevCount()
"'
"[         Returns:      The number of next/prev nodes
"'
"'         Use this procedure to see if there are multiple next/prev
"'           nodes to transfer to.
"'
::      isApproaching(atom/A)
"'
"[         A:            Atom to test
"'
"[         Returns:      True if atom is approaching the node in terms
"[                       of pathing order and its position relative to
"[                       the next/prev nodes.
"'
"'         Tests whether the atom is on the approaching side of the
"'           node, or if it has already moved 'passed' it. It does this
"'           based on the atom's position relative to the node's
"'           next/prev nodes.
"'

/MapPaths/Pather (/mob)

"'   The base type for mobs that follow the paths. Use parent_type to
"'     make your NPC's inherit from it.
"'
//   Variables:
"'
::      currentNode (/MapPaths/Node)
"'         The node the pather is currently moving towards
"'
::      prevNode (/MapPaths/Node)
"'         The node the pather was at before the currentNode
"'
::      subset (mixed)
"'         Which subset the pather is limited to. Pathers will only
"'           connect with paths that share the same subset.
"'         The default subsets are:
"'           'Blue', 'Green', 'Purple', 'Red', 'Yellow' (case-sensitive)
"'
::      graph (/MapPaths/Graph)
"'         The graph that this pather is following
"'
//   Procedures:
"'
::      nodeStep(MapPaths/Node/node)
"'
"[         node:         Node to move towards
"'
"[         Returns:      True if pather has reached node, else false
"'
"'         This is called by the node's [execute()] proc to move the
"'           pather towards the node. By default, it simply calls
"'           [step_towards()] and checks whether the pather's [loc]
"'           matches the node's. This can be overriden to support more
"'           complex movement systems, such as pixel movement. Do not
"'           call this proc directly.
"'
::      getNearestNode(maxDistance = null)
"'
"[         maxDistance:  Maximum distance to search
"'
"[         Returns:      Nearest node found in current graph, or null
"'
"'         This is a shortcut to the pather's current graph's
"'         [getNearestNode()] proc. It returns null if the pather
"'         is not already connected to a graph (for that situation,
"'         use [MapPaths.getNearestGraphNode()] instead).
"'
::      setPathGraph(MapPaths/Graph/graph)
"'
"[         graph:        Graph to connect to
"'
"'         This sets the pather's pathGraph variable and adds the pather
"'           to the graph's pathers list (while removing it from their
"'           previous graph).
"'
::      setPathNode(MapPaths/Node/node, MapPaths/Node/prev)
"'
"[         node:          Node to set as currentNode
"[         prev:          Node to set as prevNode (optional)
"'
"'         This sets the pather's current and prev nodes. If the 'prev'
"'           arg is not passed, it will automatically set it to the
"'           last currentNode. This proc will also update the pather's
"'           graph if the node's graph is different.
"'

## Version History
#######################

Version 1.0 / September 22, 2012

    Initial Release


#endif