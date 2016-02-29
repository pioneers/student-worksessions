class UsersController < ApplicationController
	before_action :authenticate_user!,  :except => [:reset_password]
	before_action :set_user, only: [:show, :edit, :update, :destroy, :sign_up, :cancel]
	def index
		if not current_user.admin? 
			redirect_to authenticated_root_path
		end
    	@users = User.all
  	end
    def reset_password
      render "users/passwords/new"
    end
  	def new
  		@user = User.new
  	end
  	def create
  		@user.save
  	end
  	def show
      
  	end
  	def edit
  	end
  	private 
  	def set_user
      @user = User.find(params[:id])
    end
end
