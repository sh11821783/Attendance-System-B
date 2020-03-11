class User < ApplicationRecord
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
  has_secure_password # AddPasswordDigestToUsersマイグレーションファイルに意味を記載。
  validates :password, presence: true, length: { minimum: 6 } # 最小文字数（6文字以上は記入）
end