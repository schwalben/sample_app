class GoodsController < ApplicationController


  before_action :logged_in_user

  def index
    
    @user = User.find(params[:user_id])
    @microposts = Micropost.left_joins(:goods).where("goods.created_by_id = ? ", @user.id).select("microposts.*, goods.created_by_id").order("microposts.created_at").paginate(page: params[:page])
    @is_mine = @user.id == current_user.id
    
  end


  def create
    
    @micropost = Micropost.find(params[:micropost_id])
    @user_id = @micropost.user_id
    user = current_user

    Good.create(micropost_id: @micropost.id, created_by_id: user.id)
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path) }
      format.js
    end
    
    
  end

  def destroy
    @micropost = Micropost.find(params[:micropost_id])
    @user_id = @micropost.user_id
    user = current_user
    Good.find_by(micropost_id: @micropost.id, created_by_id: user.id).destroy
    
    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path) }
      format.js
    end
  end


end
