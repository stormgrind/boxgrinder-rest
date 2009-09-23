namespace :db do
  desc "Erase and fill database"
  task :populate => :environment do
    require 'populator'
    require 'faker'

    [Task, Image].each(&:delete_all)

    Task.populate 20 do |t|
      t.description = Populator.sentences(1..3)
      t.status = ['COMPLETED', 'RUNNING', 'ABORTED', 'WAITING', 'FAILED', 'NEW']

      t.created_at = 2.years.ago..1.year.ago
      t.updated_at = 2.months.ago..Time.now
    end

    Image.populate 20 do |t|
      t.description = Populator.sentences(1..3)
      t.status = ['BUILT', 'BUILDING', 'PACKAGING', 'PACKAGED', 'NEW']

      t.created_at = 2.years.ago..1.year.ago
      t.updated_at = 2.months.ago..Time.now
    end
  end
end
