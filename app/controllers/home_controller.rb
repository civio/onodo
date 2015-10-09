class HomeController < ApplicationController

  def index
    @nodes = Node.all
    puts @nodes
  end
end
