require 'rails_helper'

RSpec.describe "chapters/index", type: :view do
  before(:each) do
    assign(:chapters, [
      Chapter.create!(),
      Chapter.create!()
    ])
  end

  it "renders a list of chapters" do
    render
  end
end
