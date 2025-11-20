module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!
    before_action :set_user, only: %i[edit update]

    def index
      @users = User.order(:email)
      @managers = User.managers.order(:email)
    end

    def edit
      @managers = User.managers.order(:email)
    end

    def update
      # Strong params
      if @user.update(admin_user_params)
        redirect_to admin_users_path, notice: "User updated."
      else
        @managers = User.managers.order(:email)
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def admin_user_params
      params.require(:user).permit(:role, :manager_id)
    end
  end
end
