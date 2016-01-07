require 'test_helper'

class WorksessionsControllerTest < ActionController::TestCase
  setup do
    @worksession = worksessions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:worksessions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create worksession" do
    assert_difference('Worksession.count') do
      post :create, worksession: {  }
    end

    assert_redirected_to worksession_path(assigns(:worksession))
  end

  test "should show worksession" do
    get :show, id: @worksession
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @worksession
    assert_response :success
  end

  test "should update worksession" do
    patch :update, id: @worksession, worksession: {  }
    assert_redirected_to worksession_path(assigns(:worksession))
  end

  test "should destroy worksession" do
    assert_difference('Worksession.count', -1) do
      delete :destroy, id: @worksession
    end

    assert_redirected_to worksessions_path
  end
end
