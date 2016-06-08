require 'rails_helper'

RSpec.describe "Galleries", type: :request do
  describe "GET /galleries" do
    it "works! (now write some real specs)" do
      get galleries_path
      expect(response).to have_http_status(200)
    end
  end
end
