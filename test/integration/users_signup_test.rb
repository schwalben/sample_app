require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    ActionMailer::Base.deliveries.clear
  end
  
  test "invalid signup information" do
    get signup_path
    # 第一引数の評価結果が、ブロックの呼び出し前後で変更されていないことを確認
    # 式を文字列として渡すので注意
    assert_no_difference('User.count') do
      post(
        users_path, 
        params: { 
          user: { 
            name:  "",
            email: "user@invalid",
            password: "foo",
            password_confirmation: "bar" 
          } 
        }
      )
    end
    assert_template 'users/new'
    assert_select 'form[action=?]', signup_path

  end
  
  test "valid signup information with account activation" do
    get signup_path
    assert_difference('User.count', 1) do
      post(
        users_path, 
        params: { 
          user: { 
            name:  "Example User",
            email: "user@example.com",
            password:              "password",
            password_confirmation: "password" 
          } 
        }
      )
    end
    
    assert_equal 1, ActionMailer::Base.deliveries.size
    # assigns: 対応するアクション内のインスタンス変数にアクセスできる
    user = assigns(:user) # Userscontroller.@user
    assert_not user.activated?
    
    # 有効化していない状態でログインのログインは無効
    log_in_as(user)
    assert_not is_logged_in?
    
     # 有効化トークンが不正な場合
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    
    # トークンは正しいがメールアドレスが無効な場合
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    
    # 有効化トークンが正しい場合
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
  end
  
  
end
