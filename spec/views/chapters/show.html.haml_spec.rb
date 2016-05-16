require 'rails_helper'

RSpec.describe "chapters/show", type: :view do
  before(:each) do
    @chapter = assign(:chapter, Chapter.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
