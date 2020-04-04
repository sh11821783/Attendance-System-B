class AttendancesController < ApplicationController
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    # 出勤時間が未登録であることを判定します。
    if @attendance.started_at.nil? # もし、出社時間がない場合
      # もし、出社時間が現在の時間の時、勤怠データを更新。
      if @attendance.update_attributes(started_at: Time.current)
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = "勤怠登録に失敗しました。やり直してください。"
      end
    end
    # もし、就業時間がない時、
    if @attendance.finished_at.nil?
      # もし、現在の時間が、就業時間の時、勤怠データを更新。
      if @attendance.update_attributes(finished_at: Time.current)
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = "勤怠登録に失敗しました。やり直してください。"
      end
    end
    redirect_to @user
  end
end
