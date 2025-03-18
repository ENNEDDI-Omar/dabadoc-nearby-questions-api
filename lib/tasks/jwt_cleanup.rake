namespace :jwt do
  desc "Clean up all entries in JwtDenylist"
  task cleanup: :environment do
    count = JwtDenylist.count
    JwtDenylist.destroy_all
    puts "Cleaned up #{count} entries from JwtDenylist"
  end
end