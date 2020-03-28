class UsersController < ApplicationController
  # 共通している部分@user = User.find(params[:id])をまとめた。追加したedit_basic_infoとupdate_basic_infoをログインユーザーかつ管理権限者のみが実行できるようフィルタリング設定。
  before_action :set_user, only: [:show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  # [:index, :show, :edit, :update, :destroy]にいく際は、すでにログインしているユーザーのみ
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy, :edit_basic_info, :update_basic_info]
  # 現在ログインしているユーザーのみ[:edit, :update]できる。
  before_action :correct_user, only: [:edit, :update]
  # :destroyに
  before_action :admin_user, only: [:destroy, :edit_basic_info, :update_basic_info]
  

  
  def new # ユーザー新規作成ページへ
    @user = User.new # ユーザーオブジェクトを生成し、インスタンス変数に代入。
  end
  
  def index
    # @users = User.allから下記に置き換え
    @users = User.paginate(page: params[:page]).search(params[:search]) # 名前検索フォームに必須。
  end
  
  def show # ユーザー詳細
    # @user = User.find(params[:id]),before_action :set_user
  end
  
  def create # ユーザー新規作成ページから登録（保存）まで
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
  
  def edit # 編集
    # @user = User.find(params[:id])
  end
  
  def update # 更新
    # @user = User.find(params[:id])
    # .update_attributes(user_params)　⇨　(user_params)を更新し、保存する。
    if @user.update_attributes(user_params)
      # 更新に成功した場合の処理を記述します。
      flash[:success] = "ユーザー情報を更新しました。"
      redirect_to @user
    else
      render :edit      
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end
  
  def edit_basic_info
  end

  def update_basic_info # 更新
    if @user.update_attributes(basic_info_params)
      # 更新成功時の処理
      flash[:success] = "#{@user.name}の基本情報を更新しました。"
    else
      # 更新失敗時の処理
      flash[:danger] = "#{@user.name}の更新は失敗しました。<br>" + @user.errors.full_messages.join("<br>")
    end
    redirect_to users_url
  end

  
  private
    # ストロングパラメーター　⇨　permit内のカラムをそれぞれ許可し、それ以外は許可しないよう設定。
    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :password, :password_confirmation)
    end
    
    def basic_info_params
      params.require(:user).permit(:department, :basic_time, :work_time)
    end
    
    # beforeフィルター
    
    # paramsハッシュからユーザーを取得します。
    def set_user
      @user = User.find(params[:id])
    end

    # ログイン済みのユーザーか確認します。
    def logged_in_user
      unless logged_in?
        store_location # app/helpers/sessions_helper.rbに定義済み。
        flash[:danger] = "ログインしてください。"
        redirect_to login_url
      end
    end
    
    # アクセスしたユーザーが現在ログインしているユーザーか確認します。
    def correct_user
      # current_user?は、app/helpers/sessions_helper.rbに定義済み。
      redirect_to(root_url) unless current_user?(@user)
    end
    
    # システム管理権限所有かどうか判定します。
    def admin_user
      redirect_to root_url unless current_user.admin?
    end
end
