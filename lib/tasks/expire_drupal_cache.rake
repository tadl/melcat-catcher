desc "Expire and regenerate cache"
task :recreate => :environment do
expire_action(:controller => 'drupal', :action => 'test')
`curl https://mel-catcher.herokuapp.com/drupal/test.json` 
end
