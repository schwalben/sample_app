class User < ApplicationRecord
  
  attr_accessor :remember_token
  
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
  validates(:password, { 
    presence: true, 
    length: { minimum: 6 },
    allow_nil: true
  })
  
  # 渡された文字列のハッシュ値を返す
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    return BCrypt::Password.create(string, cost: cost)
  end
  
  def self.new_token
    return SecureRandom.urlsafe_base64
  end

  def remember
    # selfをつけないとローカル変数扱いになる
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    
  end
  
  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token) 
    
    return false if remember_token.nil?
    
    # bcrypt gemのソースを参考にした書き方
    # BCrypt::Password.createは不明なsaltを付与してハッシュ化しているため、
    # 例えば以下のような処理では判定できない
    # return User.digest(remember_token) === remember_digest
    return BCrypt::Password.new(remember_digest).is_password?(remember_token)

  end
  
  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end
  
end
