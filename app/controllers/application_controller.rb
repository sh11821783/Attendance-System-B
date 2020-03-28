class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # include SessionsHelper　⇨　下記のモジュールを読み込ませることで、どのコントローラでも下記のヘルパーに定義したメソッドが使えるようになる。
  include SessionsHelper
  
  # beforフィルター
  
  
  # paramsハッシュからユーザーを取得します。
  def set_user
    @user = User.find(params[:id])
  end

  # ログイン済みのユーザーか確認します。
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "ログインしてください。"
      redirect_to login_url
    end
  end

  # アクセスしたユーザーが現在ログインしているユーザーか確認します。
  def correct_user
    redirect_to(root_url) unless current_user?(@user)
  end

  # システム管理権限所有かどうか判定します。
  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  # ページ出力前に1ヶ月分のデータの存在を確認・セットします。
  def set_one_month
    # もし @first_day = params[:date].nil?ならばDate.current.beginning_of_month
    # そうでなければ、params[:date].to_date
    @first_day = params[:date].nil? ?
    Date.current.beginning_of_month : params[:date].to_date
    @last_day = @first_day.end_of_month
    one_month = [*@first_day..@last_day] # 対象の月の日数を代入します。
    # ユーザーに紐付く一ヶ月分のレコードを検索し取得します。
    @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    
    # unless文は、条件式がfalseと評価された場合のみ、内部の処理を実行する。
    unless one_month.count == @attendances.count # それぞれの件数（日数）が一致するか評価します。
      ActiveRecord::Base.transaction do # トランザクションを開始します。
        # 繰り返し処理により、1ヶ月分の勤怠データを生成します。
        one_month.each { |day| @user.attendances.create!(worked_on: day) }
      end
      # orderメソッド:取得したデータを並び替える働きをする。
      # このように記述することで、取得したAttendanceモデルの配列をworked_onの値をもとに昇順に並び替えます。
      @attendances = @user.attendances.where(worked_on: @first_day..@last_day).order(:worked_on)
    end

  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "ページ情報の取得に失敗しました、再アクセスしてください。"
    redirect_to root_url
  end
end
