require 'rails_helper'

RSpec.describe "galleries/edit", type: :view do
  before(:each) do
    @gallery = assign(:gallery, Gallery.create!(
      :visualization_ids => "MyText",
      :story_ids => "MyText",
      :users_ids => "MyText"
    ))
  end

  it "renders the edit gallery form" do
    render

    assert_select "form[action=?][method=?]", gallery_path(@gallery), "post" do

      assert_select "textarea#gallery_visualization_ids[name=?]", "gallery[visualization_ids]"

      assert_select "textarea#gallery_story_ids[name=?]", "gallery[story_ids]"

      assert_select "textarea#gallery_users_ids[name=?]", "gallery[users_ids]"
    end
  end
end
