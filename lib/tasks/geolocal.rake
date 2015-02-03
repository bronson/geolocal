namespace :geocode do
  desc "Updates your Geocode statements"
  task :download do
    puts "downloaded"
  end

  task :update => :download do
    puts "updated"
  end

  task default: :upate
end
