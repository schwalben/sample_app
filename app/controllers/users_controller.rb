class UsersController < ApplicationController
  def new
    @user = User.new
  end
  
  def show
    # params[:id]により、url
    @user = User.find(params[:id])
  end

  def create
    # Strong Parameters
    # params[:user]で不要な属性を受け取らないようにする
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "Welcome to the Sample App!"
      
      # same: redirect_to user_url(@user)
      redirect_to @user
    else 
      render('new')
    end
    
  end
  
  private
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)  
    end
  
end
