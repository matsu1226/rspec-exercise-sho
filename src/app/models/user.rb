class User < ApplicationRecord
  # :destroy => userインスタンスが削除されるときに、関連付けられたオブジェクト(micropost)のdestroyメソッドが実行
  has_many :microposts, dependent: :destroy
  # remember_token => 変数として定義し、get/setできるが、DBには保存しない(仮想の属性)。
  attr_accessor :remember_token, :activation_token, :reset_token

  before_save :downcase_email # before_save => オブジェクト保存直前 = オブジェクトの作成時 + 更新時
  before_create :create_activation_digest   # before_create => オブジェクトが作成時のみ

  validates :name, presence: true, length: { maximum: 50 }
  # => validates (:name, {presence: true, length: {maximum: 50}} )
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i    # 正規表現 (regular expression)
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: true
  
  has_secure_password
  # bcrypt gem(ビー・クリプト)
  # セキュアパスワードの導入(パスワード.パスワードの確認を入力。=>ハッシュ化したpassword_digestをDBに保存)
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  validates :password_confirmation, presence: true

  # 渡された文字列のハッシュ値を返すクラスメソッド(tokenをdigestに変換)
  def self.digest(token)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(token, cost: cost)
  end
  
  # ランダムなトークンを返すクラスメソッド
  def self.new_token
    SecureRandom.urlsafe_base64
    # SecureRandomモジュールのurlsafe_base64メソッド
    # A–Z、a–z、0–9、"-"、"_"（64種類）からなる長さ22のランダムな文字列を返す
  end

  # 永続セッションのため、remember_tokenをhash化したものをDBのremember_digest columnに格納するインスタンスメソッド
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
    # user.remember_digest = User.digest(remember_token)
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  # remember_digest == user.digest(remember_token)? 
  # activate_digest == user.digest(activated_token)?
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  # アカウントを有効にする
  def activate
    # update_attribute(:activated, true)
    # update_attribute(:activated_at, Time.zone.now)
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    # = user.reset_digest = User.digest(reset_token)
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end
  
  # 試作feedの定義
  def feed
    Micropost.where("user_id=?", id)
  end


  private
    #メアドを全て小文字にする(emailはDBに大文字小文字の区別なしで格納)
    def downcase_email
      self.email = email.downcase
    end

    # 有効化トークンとダイジェストを作成及び代入する
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end

end
