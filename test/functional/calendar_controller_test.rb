require File.expand_path('../../test_helper', __FILE__)

class CalendarControllerTest < ActionController::TestCase
  fixtures :users

  def setup
    @owner = User.find(2)
    @other = User.find(3)
    Setting.plugin_mega_calendar['allowed_users'] = [@owner.id.to_s, @other.id.to_s]
  end

  def login_as(user)
    @request.session[:user_id] = user.id
  end

  def test_owner_can_get_their_own_filter
    filter = UserFilter.create!(:user_id => @owner.id, :filter_name => 'mine', :filter_code => [].to_json)
    login_as(@owner)

    get :get_saved_filters, :params => { :id => filter.id }

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal 'mine', body['name']
    assert_equal false, body['global']
  end

  def test_other_user_cannot_get_someone_elses_filter
    filter = UserFilter.create!(:user_id => @owner.id, :filter_name => 'mine', :filter_code => [].to_json)
    login_as(@other)

    assert_raise(ActiveRecord::RecordNotFound) do
      get :get_saved_filters, :params => { :id => filter.id }
    end
  end

  def test_any_allowed_user_can_get_a_global_filter
    filter = UserFilter.create!(:user_id => nil, :filter_name => 'shared', :filter_code => [].to_json)
    login_as(@other)

    get :get_saved_filters, :params => { :id => filter.id }

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal true, body['global']
  end

  def test_owner_can_destroy_their_own_filter
    filter = UserFilter.create!(:user_id => @owner.id, :filter_name => 'mine', :filter_code => [].to_json)
    login_as(@owner)

    assert_difference('UserFilter.count', -1) do
      get :destroy_filter, :params => { :id => filter.id }
    end
  end

  def test_other_user_cannot_destroy_someone_elses_filter
    filter = UserFilter.create!(:user_id => @owner.id, :filter_name => 'mine', :filter_code => [].to_json)
    login_as(@other)

    assert_no_difference('UserFilter.count') do
      assert_raise(ActiveRecord::RecordNotFound) do
        get :destroy_filter, :params => { :id => filter.id }
      end
    end
  end

  def test_any_allowed_user_can_destroy_a_global_filter
    filter = UserFilter.create!(:user_id => nil, :filter_name => 'shared', :filter_code => [].to_json)
    login_as(@other)

    assert_difference('UserFilter.count', -1) do
      get :destroy_filter, :params => { :id => filter.id }
    end
  end

  def test_user_not_in_allowed_users_is_blocked_before_reaching_the_filter
    filter = UserFilter.create!(:user_id => @owner.id, :filter_name => 'mine', :filter_code => [].to_json)
    disallowed = User.find(1)
    login_as(disallowed)

    get :get_saved_filters, :params => { :id => filter.id }

    assert_response :redirect
    assert_redirected_to(:controller => 'welcome')
  end
end
