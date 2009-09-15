class ApiController < ApplicationController

  def index
    @entry_points = [
            [ :tasks, tasks_url ]
    ]
  end

end
