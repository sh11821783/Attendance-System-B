class Attendance < ApplicationRecord
  # attendance.rbと1対多の関係（親）
  belongs_to :user 

  validates :worked_on, presence: true # 日付の存在性。
  validates :note, length: { maximum: 50 } # 備考欄
  
  # (1)出勤時間が存在しない場合、退勤時間は無効
  validate :finished_at_is_invalid_without_a_started_at
  
  # (1)が検証された時、下記のエラーメッセージが出る。
  def finished_at_is_invalid_without_a_started_at
    # .blank? ⇨ 値が空?の場合、true   .present? ⇨ 値がある?場合、true
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end
end
