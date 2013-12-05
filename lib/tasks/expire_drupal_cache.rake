namespace :db do
desc "Expire and regenerate cache"
task :recreate => :environment do
expire_action(:controller => 'pages', :action => 'menus')
`curl https://mel-catcher.herokuapp.com/drupal/test.json` 
end
end