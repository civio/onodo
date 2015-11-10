class NodesController < ApplicationController

  def index
    @nodes = Node.all
    @relations = Relation.all
  end
end