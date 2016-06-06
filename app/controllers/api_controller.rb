class ApiController < ApplicationController

  before_action :authenticate_user!
end
