require File.expand_path '../test_helper.rb', __FILE__

class TongueTiedPrizeListTest < TongueTiedTests

  include Rack::Test::Methods

  def setup
    # TestProviderSms.any_instance.unstub(:send_message)
    super
  end
  
  def pl
    pl = PrizeList.new(:name => 'prize name', :description => 'prize description', :claimed => false)
    assert pl.save
    return pl
  end


  ######## test below are in reverse cronological order....

  
  # def test_prize_list_claim_page_has_form_for_betwext_telephone_number
  #   get "/prizes/claim/#{pl.id}"
  #   assert_match /\<input.*? name\=\'\'.*?\>/, last_response.body
  # end

  # def test_prize_list_is_associated_with_betwext_keyword do
  #
  # end
  
  def test_prize_list_claim_link_exists
    get "/prizes/claim/#{pl.id}"
    assert last_response.ok?
  end
  
  def test_prize_list_has_default_image_when_no_image_is_present 
    pl
    get '/prizes'
    assert last_response.ok?
    assert_match /\/\/tonguetied.rocks\/images\/prizes\/lips\.gif/, last_response.body
  end
  
  def test_prize_list_has_image_url
    pl = PrizeList.new(:name => 'prize name', :description => 'description', :image_url => 'http://tonguetied.rocks/images/prizes/someprize.jpg')
    assert pl.save
  end

  def test_prize_list_renders_with_prizes
    pl
    get "/prizes"
    assert_match /prize name/, last_response.body, PrizeList.count
  end

  def test_prize_list_renders
    get "/prizes"
    assert last_response.ok?, 'failed to render'
  end

  def test_prize_list_model_exists
    pl = PrizeList.new(:name => 'prize name', :description => 'prize description', :claimed => false)
    assert pl.save
  end

end