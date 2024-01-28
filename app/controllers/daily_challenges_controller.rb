class DailyChallengesController < BaseController
  def new
    @daily = current_user.dailies.find(params[:daily_id])
    @challenges = current_user.challenges.where(game: @game).not_achieved.order(Arel.sql("opponent_id IS NOT NULL, opponent_id ASC"))
    @selected_challenge_ids = if @daily.daily_challenges.pluck(:challenge_id).present?
                                @daily.daily_challenges.pluck(:challenge_id)
                              else
                                @challenges.in_progress.pluck(:id)
                              end
  end

  def create # rubocop:disable Metrics/AbcSize
    error = validate_create_param!
    return redirect_to new_game_daily_challenge_path(@game, params[:daily_id]), flash: { error: } if error

    daily = current_user.dailies.find(params[:daily_id])
    @selected_challenges = daily.daily_challenges
    ActiveRecord::Base.transaction do
      deleting = @selected_challenges.where.not(challenge_id: daily_challenge_params[:challenge_ids])
      deleting&.destroy_all

      daily_challenge_params[:challenge_ids].each do |challenge_id|
        next if @selected_challenges.present? && @selected_challenges.pluck(:challenge_id).include?(challenge_id.to_i)

        DailyChallenge.create!(daily_id: params[:daily_id], challenge_id:)
      end
      daily.in_progress!
    end
    notice = "「#{daily.character.display_name}」でプレイを開始します"
    redirect_to new_game_daily_result_path(@game, params[:daily_id]), notice:
  end

  private

    def daily_challenge_params
      params.permit(:daily_id, challenge_ids: [])
    end

    def validate_create_param!
      return if daily_challenge_params[:challenge_ids].present?

      "チャレンジする課題を選択してください"
    end
end
