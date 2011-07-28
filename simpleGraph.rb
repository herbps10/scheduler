#!/usr/bin/ruby

class Vertex
	attr_accessor :id

	def initialize(id)
		@id = id
	end

	def compare(vertex)
		return true if vertex.id == id
		return false
	end
end

class Edge
	attr_accessor :id1, :id2

	def initialize(id1, id2)
		@id1 = id1
		@id2 = id2
	end
	
	def compare(edge)
		return true if (edge.id1 == @id1 and edge.id2 == @id2) or (edge.id1 == @id2 and edge.id2 == @id1)
		return false
	end
end

class Graph
	attr_accessor :vertexes, :edges

	def initialize()
		@vertexes = []
		@edges = []
	end

	def addVertex(vertex)
		@vertexes.push(vertex)
	end

	def removeVertex(vertex)
		removeVertexByID(vertex.id)
	end

	def removeVertexByID(id)
		@vertexes.delete_if { |v| v.id == id }
		@edges.delete_if { |e| e.id1 == id or e.id2 == id }
	end

	def addEdge(edge)
		@edges.push(edge)
	end

	def adjacent?(id1, id2)
		@edges.each do |e|
			return true if (e.id1 == id1 and e.id2 == id2) or (e.id1 == id2 and e.id2 == id1)
		end

		return false
	end

	def getVertex(id)
		@vertexes.each do |v|
			return v if v.id == id
		end
	end

	# Returns all the vertex ids that are adjacent to the given vertex id
	def adjacent(id)
		ids = []

		@edges.each do |e|
			if e.id1 == id
				ids.push e.id2
			elsif e.id2 == id
				ids.push e.id1
			end
		end

		return ids
	end

	def independentSet
		
	end

	def size
		return @vertexes.length
	end

	def each
		@vertexes.each { |v| yield v }
	end

	def clone
		cloned = Graph.new
		cloned.vertexes = @vertexes.clone
		cloned.edges = @edges.clone

		return cloned
	end

	def concat(graph)
		graph.vertexes.each do |v|
			addVertex(v)
		end

		graph.edges.each do |e|
			addEdge(e)
		end
	end

	def compareVertexes(graph)
		return false if graph.vertexes.length != @vertexes.length

		graphEqual = true
		graph.vertexes.each do |vertex|
			vertexEqual = false
			@vertexes.each do |myVertex|
				if myVertex.compare(vertex) == true
					vertexEqual = true
					break
				end
			end

			if vertexEqual == false
				graphEqual = false
				break
			end
		end

		return graphEqual
	end

	def compareEdges(graph)
		return false if graph.edges.length != @edges.length

		graphEqual = true
		graph.edges.each do |edge|
			edgeEqual = false
			@edges.each do |myEdge|
				puts myEdge.inspect
				puts edge.inspect
				puts
				if myEdge.compare(edge) == true
					edgeEqual = true
					break
				end
			end

			if edgeEqual == false
				graphEqual = false
				break
			end
		end

		return graphEqual
	end

	def compare(graph)
		return true if (compareEdges(graph) == true and compareVertexes(graph) == true)
		return false
	end
end

# Initialize the graph

graph = Graph.new

graph.addVertex(Vertex.new(1));
graph.addVertex(Vertex.new(2));
graph.addVertex(Vertex.new(3));
graph.addVertex(Vertex.new(4));
graph.addVertex(Vertex.new(5));
graph.addVertex(Vertex.new(6));

graph.addEdge(Edge.new(1, 2));
graph.addEdge(Edge.new(1, 6));

graph.addEdge(Edge.new(2, 1))
graph.addEdge(Edge.new(2, 3))
graph.addEdge(Edge.new(2, 5))

graph.addEdge(Edge.new(3, 2))
graph.addEdge(Edge.new(3, 4))

graph.addEdge(Edge.new(4, 3))
graph.addEdge(Edge.new(4, 5))

graph.addEdge(Edge.new(5, 2))
graph.addEdge(Edge.new(5, 4))
graph.addEdge(Edge.new(5, 6))

graph.addEdge(Edge.new(6, 1))
graph.addEdge(Edge.new(6, 5))
graph.addEdge(Edge.new(1, 2))

def max(graph, level)
	puts level
	ret = []
	if graph.size == 0
		return []
	elsif graph.size == 1
		puts " * " * level + graph.inspect
		return [graph]	
	else
		graph.each do |vertex|
			g = graph.clone
			
			graph.adjacent(vertex.id).each do |adjID|
				g.removeVertexByID(adjID)
			end
			
			g.removeVertex(vertex)

			puts "Each: "
			puts " - " * level + vertex.inspect
			puts " - " * level + g.inspect

			max(g, level + 1).each do |subGraph|
				subGraph.addVertex(vertex)
				ret.push subGraph
			end
		end
	end

	return ret
end

out = max(graph, 1)

puts 
puts
out.each do |o|
	puts "Graph:"
	puts o.vertexes.inspect
	puts
end
