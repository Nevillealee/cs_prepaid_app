class DashboardsController < ApplicationController
  before_action :authenticate_user!
  def index
    return 200
  end
end
