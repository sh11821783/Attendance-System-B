class UsersController < ApplicationController
  
  def new
    @user = User.new # ユーザーオブジェクトを生成し、インスタンス変数に代入。
  end
  
  def show
    @user = User.find(params[:id])
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = '新規作成に成功しました。'
      redirect_to @user
      # 保存に成功した後、リダイレクトしてユーザー情報ページへ遷移
      # 遷移したページで保存が成功したことを知らせるフラッシュメッセージを表示
    else
      render :new
    end
  end
  
  private
    # ストロングパラメーター　⇨　permit内をそれぞれ許可し、それ以外は許可しないよう設定。
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
