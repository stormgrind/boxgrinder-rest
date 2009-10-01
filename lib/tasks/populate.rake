namespace :db do
  desc "Erase and fill database"
  task :populate => :environment do
    require 'populator'
    require 'faker'

    include Defaults

    [Task, Image, Definition, Package].each(&:delete_all)

    Task.populate 20 do |t|
      t.description = Populator.sentences(1..3)
      t.status = Task::STATUSES.values
      # we don't want to add task here
      t.artifact = Defaults::ARTIFACTS.values.reject{|item| item.eql?(ARTIFACTS[:task])}

      t.action =
              case t.artifact
                when ARTIFACTS[:image] then
                  Image::ACTIONS.values
                when ARTIFACTS[:definition] then
                  Definition::ACTIONS.values
                when ARTIFACTS[:package] then
                  Package::ACTIONS.values
              end

      t.artifact_id = 1..20

      t.created_at = 2.years.ago..1.year.ago
      t.updated_at = 2.months.ago..Time.now
    end

    Definition.populate 10 do |d|
      d.description = Populator.sentences(1..3)
      d.status = Definition::STATUSES.values

      d.created_at = 2.years.ago..1.year.ago
      d.updated_at = 2.months.ago..Time.now

      Image.populate 0..5 do |i|
        i.description = Populator.sentences(1..3)
        i.status = Image::STATUSES.values
        i.definition_id = d.id

        i.image_format = Image::FORMATS.values[rand(Image::FORMATS.length)]

        i.created_at = 2.years.ago..1.year.ago
        i.updated_at = 2.months.ago..Time.now

        Package.populate 0..3 do |p|
          p.description = Populator.sentences(1..3)
          p.status = Package::STATUSES.values
          p.image_id = i.id

        end if i.status.eql?( Image::STATUSES[:built] )
      end if d.status.eql?( Definition::STATUSES[:created] )
    end
  end
end
