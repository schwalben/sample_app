class SearchController < ApplicationController
  
  
  
  def index
    
    @target = params[:target]
    @user = current_user
    if @target == "users"
      return search_user
    elsif @target == "microposts"
      return search_micropost
    else
      redirect_to root_url
    end
    
  end


  private
  
    def search_user
      @title = "Search Users"
      @users = User.where('name LIKE ?', "%#{params[:search_condition]}%").paginate(page: params[:page])
      render('index')  
    end
  
    def search_micropost
      @title = "Search Microposts"
      @microposts = Micropost.where('content LIKE ?', "%#{params[:search_condition]}%").joins(:user).left_joins(:goods).where("goods.created_by_id = ? or goods.created_by_id is ? ", current_user.id, nil).select("microposts.*, goods.created_by_id").paginate(page: params[:page])
      render('index')  
    end

end
