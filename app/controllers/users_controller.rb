class UsersController < ApplicationController
  
  before_action :logged_in_user, only: [:edit, :update, :index, :destroy, 
                                        :following, :followers, :show]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: [:destroy]
  
  def index
    # per_page: default 30
    @users = User.where(activated: true).paginate(page: params[:page], per_page: 20)
  end
  
  
  def show
    # params[:id]により、url
    @user = User.find(params[:id])
    @microposts = @user.microposts.left_joins(:goods)
        .where("goods.created_by_id = ? or goods.created_by_id is ? ", current_user.id, nil)
          .select("microposts.*, goods.created_by_id").paginate(page: params[:page])
    redirect_to root_url and return unless @user.activated
  end
  
  def new
    @user = User.new
  end

  def create
    # Strong Parameters
    # params[:user]で不要な属性を受け取らないようにする
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else 
      render('new')
    end
    
  end
  
  
  def edit
    
    
    
    
  end
  
  def update
    
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to(user_path(@user))
    else
      render 'edit'
    end
    
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end
  
  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end
  
  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end
  
  
  
  private
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)  
    end
  
    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
end
