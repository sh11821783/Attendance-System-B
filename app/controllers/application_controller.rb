class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # include SessionsHelper　⇨　下記のモジュールを読み込ませることで、どのコントローラでも下記のヘルパーに定義したメソッドが使えるようになる。
  include SessionsHelper
end
