require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedCampaign < TongueTiedTests

  include Rack::Test::Methods

  ######## test below are in reverse cronological order....

  def test_campaign_has_keyword
    c = Campaign.new(:name => "Campaign Name", :keyword => "keyword")
    assert c.save
    assert_equal "KEYWORD", c.keyword
  end

  def test_campaign_exists
    c = Campaign.new(:name => "Campaign Name", :keyword => "key")
    assert c.save
  end

end