class User < ApplicationRecord
  # 「remember_token」という仮想の属性を作成します。
  attr_accessor :remember_token
  # データベースでメールアドレスの大文字小文字を区別せず小文字として登録されるよう対応
  before_save { self.email = email.downcase } # self.email = email.downcaseを渡してユーザーのメールアドレスを設定
  
  
  # nameが存在し、最大文字数は、５０文字以上まで
  validates :name,  presence: true, length: { maximum: 50 }
  # このeメールは、有効なメールアドレスかを検証
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 100 },
                    format: { with: VALID_EMAIL_REGEX },
                    # uniqueness: trueというオブションをvalidatesメソッドに指定。
                    # eメールなど一つしか存在しないものかを判定。
                    uniqueness: true
  #affiliation（所属）が存在し、最大文字数は、５０文字以上まで
  validates :affiliation,  presence: true, length: { maximum: 50 }
  has_secure_password # AddPasswordDigestToUsersマイグレーションファイルに意味を記載。
  # 最小文字数（6文字以上は記入）、presence（存在の有無）、allow_nil: true（すでにログインしているので再度パスワードを打たなくえすむ）
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  
  # 渡された文字列のハッシュ値を返します。
  def User.digest(string)
    cost = 
      if ActiveModel::SecurePassword.min_cost
        BCrypt::Engine::MIN_COST
      else
        BCrypt::Engine.cost
      end
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返します。
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # 永続セッションのためハッシュ化したトークンをデータベースに記憶します。
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # トークンがダイジェストと一致すればtrueを返します。
  def authenticated?(remember_token)
    # ダイジェストが存在しない場合はfalseを返して終了します。
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
  # ユーザーのログイン情報を破棄します。ユーザーがログアウトできるようにする。
  def forget
    update_attribute(:remember_digest, nil)
  end
end