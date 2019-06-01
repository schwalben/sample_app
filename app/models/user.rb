class User < ApplicationRecord
  
  # DB側は大文字小文字を区別するため
  before_save { self.email = email.downcase }
  
  validates(:name,  { presence: true, length: { maximum: 50 } })
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates(:email, { 
      presence: true, 
      length: { maximum: 255 },
      format: { with: VALID_EMAIL_REGEX },
      uniqueness: { case_sensitive: false}
  })
  # この一行でセキュアにハッシュ化したパスワードを、データベース内のpassword_digestという属性に保存できるようになる
  has_secure_password
  validates(:password,  { presence: true, length: { minimum: 6 } })
end
