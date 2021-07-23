class User < ApplicationRecord
  before_save { self.email = email.downcase }   # emailはDBに大文字小文字の区別なしで格納
  validates :name, presence: true, length: { maximum: 50 }
  # => validates (:name, {presence: true, length: {maximum: 50}} )
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i    # 正規表現 (regular expression)
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: true
  
  has_secure_password
  # bcrypt gem(ビー・クリプト)
  # セキュアパスワードの導入(パスワード.パスワードの確認を入力。=>ハッシュ化したものをDBに保存)
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true

    # 渡された文字列のハッシュ値を返す
    # def User.digest(string)
    #   cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
    #                                                 BCrypt::Engine.cost
    #   BCrypt::Password.create(string, cost: cost)
    # end
end
