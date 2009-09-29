namespace :db do
  desc "Erase and fill database"
  task :populate => :environment do
    require 'populator'
    require 'faker'

    include Defaults

    [Task, Image, Definition, Package].each(&:delete_all)

    Task.populate 20 do |t|
      t.description = Populator.sentences(1..3)
      t.status = TASK_STATUSES.values
      t.artifact = ARTIFACTS.values

      t.action =
              case t.artifact
                when ARTIFACTS[:image] then
                  IMAGE_ACTIONS.values
                when ARTIFACTS[:definition] then
                  DEFINITION_ACTIONS.values
                when ARTIFACTS[:package] then
                  PACKAGE_ACTIONS.values
              end

      t.artifact_id = 1..20

      t.created_at = 2.years.ago..1.year.ago
      t.updated_at = 2.months.ago..Time.now
    end

    Definition.populate 10 do |d|
      d.description = Populator.sentences(1..3)
      d.status = DEFINITION_STATUSES.values

      d.created_at = 2.years.ago..1.year.ago
      d.updated_at = 2.months.ago..Time.now

      Image.populate 0..5 do |i|
        i.description = Populator.sentences(1..3)
        i.status = IMAGE_STATUSES.values
        i.definition_id = d.id

        i.image_format = IMAGE_FORMATS.values[rand(IMAGE_FORMATS.length)]

        i.created_at = 2.years.ago..1.year.ago
        i.updated_at = 2.months.ago..Time.now

        Package.populate 0..3 do |p|
          p.description = Populator.sentences(1..3)
          p.status = PACKAGE_STATUSES.values
          p.image_id = i.id

        end if i.status.eql?( IMAGE_STATUSES[:built] )
      end if d.status.eql?( DEFINITION_STATUSES[:created] )

    end
  end
end
