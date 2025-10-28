# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "The Empire Strikes Back" }])
#   Character.create(name: "Luke", parent_id: movies.first.id)

puts "=" * 80
puts "Starting Database Seeding..."
puts "=" * 80

# Clear existing data
puts "\nClearing existing data..."
Task.destroy_all
Project.destroy_all
User.destroy_all

puts "✓ Existing data cleared"

# ============================================================================
# CREATE USERS
# ============================================================================

puts "\n" + "=" * 80
puts "Creating Users..."
puts "=" * 80

puts "\nCreating 1 Admin user..."
admin = User.create!(
  name: "Admin User",
  email: "admin@example.com",
  password: "Asdf@1234",
  password_confirmation: "Asdf@1234",
  role: :admin
)
puts "✓ Admin created: #{admin.email}"

puts "\nCreating 5 Manager users..."
managers = []
5.times do |i|
  manager = User.create!(
    name: "Manager #{i + 1}",
    email: "manager#{i + 1}@example.com",
    password: "Asdf@1234",
    password_confirmation: "Asdf@1234",
    role: :manager
  )
  managers << manager
  puts "✓ Manager #{i + 1} created: #{manager.email}"
end

puts "\nCreating 24 Contributor users..."
contributors = []
24.times do |i|
  contributor = User.create!(
    name: "Contributor #{i + 1}",
    email: "contributor#{i + 1}@example.com",
    password: "Asdf@1234",
    password_confirmation: "Asdf@1234",
    role: :contributor
  )
  contributors << contributor
  puts "✓ Contributor #{i + 1} created: #{contributor.email}"
end

# ============================================================================
# CREATE PROJECTS AND TASKS
# ============================================================================

puts "\n" + "=" * 80
puts "Creating Projects and Tasks..."
puts "=" * 80

project_count = 0
task_count = 0
contributor_index = 0

# Each manager gets 3 projects
managers.each_with_index do |manager, manager_idx|
  puts "\n--- Manager #{manager_idx + 1} (#{manager.name}) ---"
  
  3.times do |project_idx|
    project_count += 1
    
    # Create project
    project = Project.create!(
      title: "Project #{project_count} - Manager #{manager_idx + 1}",
      description: "This is project #{project_count} managed by #{manager.name}. It contains important tasks for the team.",
      manager_id: manager.id,
      status: "active"
    )
    
    puts "\n  Project #{project_count}: #{project.title}"
    
    # Each project gets 5 tasks
    5.times do |task_idx|
      task_count += 1
      
      contributor = contributors[contributor_index % contributors.length]
      contributor_index += 1
      
      initial_status = ["not_started", "in_progress"].sample
      
      task = Task.create!(
        title: "Task #{task_count} - #{project.title}",
        description: "This is task #{task_count} for project #{project.title}. Assigned to #{contributor.name}.",
        project_id: project.id,
        contributor_id: contributor.id,
        status: initial_status
      )
      
      puts "    ✓ Task #{task_count}: #{task.title} (Status: #{initial_status}, Assigned to: #{contributor.name})"
    end
  end
end

# ============================================================================
# SUMMARY
# ============================================================================

puts "\n" + "=" * 80
puts "Database Seeding Complete!"
puts "=" * 80

puts "\nSummary:"
puts "  Users Created:"
puts "    - Admins: 1"
puts "    - Managers: 5"
puts "    - Contributors: 24"
puts "    - Total Users: #{User.count}"

puts "\n  Projects Created:"
puts "    - Total Projects: #{Project.count}"
puts "    - Projects per Manager: 3"

puts "\n  Tasks Created:"
puts "    - Total Tasks: #{Task.count}"
puts "    - Tasks per Project: 5"

puts "\n  Distribution:"
puts "    - Total Managers: #{User.where(role: :manager).count}"
puts "    - Total Contributors: #{User.where(role: :contributor).count}"
puts "    - Total Admins: #{User.where(role: :admin).count}"

puts "\n" + "=" * 80
puts "Sample Login Credentials:"
puts "=" * 80
puts "\nAdmin:"
puts "  Email: admin@example.com"
puts "  Password: Asdf@1234"

puts "\nManager 1:"
puts "  Email: manager1@example.com"
puts "  Password: Asdf@1234"

puts "\nContributor 1:"
puts "  Email: contributor1@example.com"
puts "  Password: Asdf@1234"

puts "\n" + "=" * 80
puts "Seeding finished successfully!"
puts "=" * 80
