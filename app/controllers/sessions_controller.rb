class SessionsController < ApplicationController
  before_filter :set_cookorama_user, only: [:create]

  def new
  end

  def create
    if @result.empty?
      flash.now[:alert] = "Не вірна адреса електронної пошти або пароль"
      render 'new'
    else
      flash[:success] = "Вітаємо на Cookorama!"
      redirect_to root_path
    end
  end
  # def create
  #   user = User.find_by(email: params[:session][:email].downcase)
  #   if user && user.authenticate(params[:session][:password])
  #     flash[:success] = "Вітаємо на Cookorama!"
  #     redirect_to root_path
  #   else
  #     flash.now[:alert] = "Не вірна адреса електронної пошти або пароль"
  #     render 'new'
  #   end
  # end

  def destroy
    $agent = nil
    session[:user] = nil
    redirect_to root_path
  end

  private

    def set_cookorama_user
      $agent = Mechanize.new { |a|
        a.user_agent_alias = "Mac Safari"
      }

      $agent.get("http://cookorama.net/uk/login/") do |page|
        form = page.forms.first
        form.login = params[:session][:email]
        form.password = params[:session][:password]
        result = form.submit
        @result = result.search("ul li.user-row")
      end
    end
end
