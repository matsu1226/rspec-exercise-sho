class User < ApplicationRecord
  # remember_token => 変数として定義し、get/setできるが、DBには保存しない(仮想の属性)。
  attr_accessor :remember_token 

  before_save { self.email = email.downcase }   # emailはDBに大文字小文字の区別なしで格納
  validates :name, presence: true, length: { maximum: 50 }
  # => validates (:name, {presence: true, length: {maximum: 50}} )
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i    # 正規表現 (regular expression)
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: true
  
  has_secure_password
  # bcrypt gem(ビー・クリプト)
  # セキュアパスワードの導入(パスワード.パスワードの確認を入力。=>ハッシュ化したものをDBに保存)
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
  # remember_digest == user.digest(remember_token) ?
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCcrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

end
