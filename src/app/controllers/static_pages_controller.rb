class StaticPagesController < ApplicationController
  def home  # homeの機能 => login時:micropost_form, feed / logout時:sign_up_url
    if logged_in?
      @micropost  = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
