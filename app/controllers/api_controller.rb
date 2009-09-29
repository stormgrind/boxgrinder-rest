class ApiController < ApplicationController

  def show
    @entry_points = [
            [ :tasks, tasks_url ],
            [ :images, images_url ],
            [ :packages, packages_url ],
            [ :definitions, definitions_url ]
    ]
  end

end
