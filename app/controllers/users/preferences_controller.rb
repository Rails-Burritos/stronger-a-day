class Users::PreferencesController < ApplicationController
  include Devise::Controllers::Rememberable

  def edit
    @preference = current_user.preference
    # FIXME: なぜか false になる
    @remember_me = remember_me_is_active?(current_user)
  end

  def update
    @preference = current_user.preference
    if @preference.update(update_params)
      if remember_me_param == "1"
        current_user.remember_me!
      end
      if remember_me_param == "0"
        current_user.forget_me!
      end
      redirect_to edit_preference_path, notice: "更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

    def update_params
      params.require(:user_preference).permit(:show_tips, :show_usage, :public)
    end

    def remember_me_param
      params.require(:user_preference).permit(:remember_me)[:remember_me]
    end
end
