require 'asana'
require 'phabricator'
require 'colorize'

class TaskMigrator
  PRIORITY_SHORTCUTS = {
    'h' => 'high',
    'l' => 'low',
    'w' => 'wishlist'
  }

  def initialize
    Asana.configure do |client|
      client.api_key = ENV['ASANA_API_KEY']
    end
  end

  def run!
    project_id = ARGV[0]
    project = Asana::Project.find(project_id)
    puts "=== Migrating project: #{project.name}".bold.white

    total = project.tasks.count
    project.tasks.each_with_index do |task, i|
      task = Asana::Task.find(task.id)

      # Skip if this task has already been closed.
      next if task.completed

      puts
      puts "= Task #{i}/#{total}".white
      puts "#{'Title:'.white} #{task.name}"
      puts "#{'Notes:'.white} #{task.notes || '(none)'}"

      url = "https://app.asana.com/0/#{project_id}/#{task.id}"
      puts "#{'URL:'.white} #{url}"

      # Check if it was already moved to Phab or not.
      if task.stories.any? {|story| story.text =~ /Moved to Phab!/ }
        puts "Already moved to Phab; skipping.".red
        next
      end

      print "Migrate? [Yn] ".yellow
      if $stdin.gets.chomp.downcase == 'y'
        print "Priority? [hlw] "
        priority = $stdin.gets.chomp.downcase
        priority = PRIORITY_SHORTCUTS[priority] || 'normal'

        print "Projects? (space separated) "
        projects = $stdin.gets.chomp.split(' ')

        phab_task = Phabricator::Maniphest::Task.create(
          task.name,
          task.notes + "\n\nPreviously from: #{url}.",
          ['Product'] + projects,
          priority
        )

        phab_url = "#{ENV['PHAB_HOST']}/T#{phab_task.id}"
        puts "Added to Phab!: #{phab_url}".green

        task.create_story :text => "Moved to Phab!: #{phab_url}"
      else
        puts "OK, skipping.".red
      end
    end
  end
end

migrator = TaskMigrator.new
migrator.run!
