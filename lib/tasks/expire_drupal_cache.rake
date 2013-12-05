desc "Expire and regenerate cache"
task :recreate => :environment do
ActionController::Base.new.expire_fragment(%r{/})
`curl https://mel-catcher.herokuapp.com/drupal/test.json` 
end
