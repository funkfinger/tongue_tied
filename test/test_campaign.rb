require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedCampaign < TongueTiedTests

  include Rack::Test::Methods

  

  ######## test below are in reverse cronological order....

  # def test_can_create_list_of_participating_numbers_in_campaign
  #   
  # end

  def test_catch_all_campaign_is_created_if_campaign_does_not_exist
    count = Campaign.count
    t = TextMessage.new("body" => "blah me", "from_number" => "1212", :to_number => "111")
    assert t.save
    assert_equal count + 1, Campaign.count
  end


  def test_campaign_has_keyword
    c = Campaign.new(:name => "Campaign Name", :keyword => "keyword", :to_number => "111")
    assert c.save
    assert_equal "KEYWORD", c.keyword
  end

  def test_campaign_exists
    c = Campaign.new(:name => "Campaign Name", :keyword => "key", :to_number => "111")
    assert c.save
  end

end