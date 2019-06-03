# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://rails-tutorial-mhartl.c9users.io/rails/mailers/user_mailer/account_activation
  def account_activation
    user = User.first
    user.activation_token = User.new_token
    
    UserMailer.account_activation(user)
  end

  # Preview this email at https://2000f28540cc4ddcb2d8360a4d1660c2.vfs.cloud9.us-east-2.amazonaws.com//rails/mailers/user_mailer/password_reset
  def password_reset
    user = User.first
    user.reset_token = User.new_token
    UserMailer.password_reset(user)
  end

end
