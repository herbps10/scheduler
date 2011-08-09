#!/usr/bin/ruby
BLUE = 0
RED = 1

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
	attr_accessor :id1, :id2, :color

	def initialize(id1, id2, color)
		@id1 = id1
		@id2 = id2
		@color = color
	end
	
	def compare(edge)
		return true if (edge.id1 == @id1 and edge.id2 == @id2) or (edge.id1 == @id2 and edge.id2 == @id1)
		return false
	end
end

class Graph
	attr_accessor :vertexes, :edges, :red, :blue

	def initialize()
		@vertexes = []
		@edges = []
		@blue = []
		@red = []
	end

	def addVertex(vertex)
		@vertexes.push(vertex)
		@blue.push(vertex) if vertex.color == BLUE
		@red.push(vertex) if vertex.color = RED
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

	def checkRed
		return false if @red.length < 3
		@red.each do |r|
			
		end
	end

	def checkBlue
		return false if @blue.length < 3
	end
end

# Initialize the graph

graph = Graph.new

graph.addVertex(Vertex.new(0))
graph.addVertex(Vertex.new(1))
graph.addVertex(Vertex.new(2))

graph.addEdge(0, 1, RED)
graph.addEdge(0, 2, RED)
graph.addEdge(1, 2, RED)

=begin
9.times do |i|
	graph.addVertex(Vertex.new(i))
end


bottom = 0
(bottom..9).to_a.each do |i|
	bottom += 1
	(bottom..9).each do |n|
		graph.addEdge(i, s, BLUE)
	end
end
=end
