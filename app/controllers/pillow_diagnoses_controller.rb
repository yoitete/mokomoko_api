class PillowDiagnosesController < ApplicationController
  # 診断履歴一覧を取得（ログインユーザーのみ）
  def index
    @diagnoses = PillowDiagnosis.where(user_id: @current_user.id).order(created_at: :desc)
    render json: @diagnoses
  end

  # 診断結果を保存
  def create
    @diagnosis = PillowDiagnosis.new(diagnosis_params)
    @diagnosis.user_id = @current_user.id

    if @diagnosis.save
      # 最大10件を超えたら古い順に削除
      user_diagnoses = PillowDiagnosis.where(user_id: @current_user.id).order(created_at: :desc)
      if user_diagnoses.count > 10
        user_diagnoses.offset(10).destroy_all
      end

      render json: { message: "診断結果を保存しました", diagnosis: @diagnosis }, status: :created
    else
      render json: { errors: @diagnosis.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # 診断結果を削除
  def destroy
    @diagnosis = PillowDiagnosis.find_by(id: params[:id], user_id: @current_user.id)

    if @diagnosis
      @diagnosis.destroy
      render json: { message: "診断結果を削除しました" }
    else
      render json: { error: "診断結果が見つかりません" }, status: :not_found
    end
  end

  private

  def diagnosis_params
    params.require(:pillow_diagnosis).permit(
      :sleeping_position, :height, :material_preference, :order_interest, :price_range
    )
  end
end
