module GoodsHelper
  
  def can_good?(user_id, micropost_id)
    return !Good.find_by(micropost_id: micropost_id, created_by_id: user_id)
  end
  
end
