class ApiController < ApplicationController

  def show
    @entry_points = [
            [ :tasks, tasks_url ],
            [ :images, images_url ]
    ]
  end

end
