class User < ApplicationRecord
  
  # 複数形
  has_many :microposts, { dependent: :destroy }
  
  has_many :active_relationships, {
              class_name: "Relationship",
              foreign_key: "follower_id",
              dependent:   :destroy
  }
  has_many :passive_relationships, {
              class_name: "Relationship",
              foreign_key: "followed_id",
              dependent:   :destroy
  }
  # user.followedsは不適切なので明示的に名前を指定する
  # throw -> 
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower
  
  has_many :goods
  

  
  attr_accessor :remember_token, :activation_token, :reset_token
  
  # DB側は大文字小文字を区別するため
  before_save :downcase_email
  
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
  before_create :create_activation_digest
  
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
  def authenticated?(attribute, token) 
    
    digest = self.send("#{attribute}_digest")
    
    
    # 何故remember_tokenではなく, digestのnilチェックに変更したのか？
    # nilだとPassword.newでエラーが発生するから?
    return false if digest.nil?
    
    # bcrypt gemのソースを参考にした書き方
    # BCrypt::Password.createは不明なsaltを付与してハッシュ化しているため、
    # 例えば以下のような処理では判定できない
    # return User.digest(remember_token) === remember_digest
    return BCrypt::Password.new(digest).is_password?(token)

  end
  
  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  def activate
    update_columns({ activated: true, activated_at: Time.zone.now })
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end
  
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns({ reset_digest: User.digest(self.reset_token), reset_sent_at: Time.zone.now })
  end
  
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end
  
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id).left_joins(:goods).where("goods.created_by_id = ? or goods.created_by_id is ? ", id, nil).select("microposts.*, goods.created_by_id")
  end
  
  def follow(other_user)
    following << other_user
  end
  
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
  end
  
  def following?(other_user)
    return following.include?(other_user)
  end
  
  
  private
  
    def downcase_email
      self.email.downcase!
    end
  
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

  
end
