class NodesController < ApplicationController

  # GET /nodes
  def index
    @nodes = Node.all
    @relations = Relation.all
  end
end