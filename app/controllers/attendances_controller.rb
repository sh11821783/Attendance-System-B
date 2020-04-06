class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :update_one_month]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :admin_or_correct_user, only: [:update, :edit_one_month, :update_one_month]
  before_action :set_one_month, only: :edit_one_month

  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil? # もし、出社時間がない場合
      # 出社時間が現在の時間の時、勤怠データを更新。
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    # もし、就業時間がない時、
    elsif @attendance.finished_at.nil?
      # もし、現在の時間が、就業時間の時、勤怠データを更新。
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  def edit_one_month
  end
  
  def update_one_month
    ActiveRecord::Base.transaction do # トランザクションを開始。
    # データベースの操作を保障したい処理を以下に記述。
    # Attendanceモデルオブジェクトのidと、各カラムの値が入った更新するための情報であるitemを指す。
    attendances_params.each do |id, item|
      attendance = Attendance.find(id)
      # !をつけている場合はfalseでは無く例外処理を返す。
      attendance.update_attributes!(item) # ここにトランザクションを適用。
      end
    end
    # 全ての繰り返し処理が問題なく完了した時は、以下２行の処理が実行される。
    flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
    redirect_to user_url(date: params[:date])
  # トランザクションによる例外処理の分岐を以下に記述。
  rescue ActiveRecord::RecordInvalid # 以下に例外が発生した時は、以下２行の処理が実行される。
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end
  
  private
    # 1ヶ月分の勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end
    
    # beforeフィルター

    # 管理権限者、または現在ログインしているユーザーを許可。
    def admin_or_correct_user
      @user = User.find(params[:user_id]) if @user.blank?
      unless current_user?(@user) || current_user.admin?
        flash[:danger] = "編集権限がありません。"
        redirect_to(root_url)
      end  
    end
end
