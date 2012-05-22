# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake create_sessions_table')
  # config.action_controller.session_store = :active_record_store

  # Enable page/fragment caching by setting a file-based store
  # (remember to create the caching directory and make it readable to the application)
  # config.action_controller.fragment_cache_store = :file_store, "#{RAILS_ROOT}/cache"

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # Use Active Record's schema dumper instead of SQL when creating the test database
  # (enables use of different database adapters for development and test environments)
  # config.active_record.schema_format = :ruby

<<<<<<< .mine
require 'active_support'
require 'active_record'
require 'action_controller'
require 'action_mailer'
require 'action_web_service'

# Since this application serves several different sites, load the SITE from the
# environment.  See 'lib/productize.rb' for full documentation on how we make a 
# generic site into a hierarchical structure of specific sites.
SITE = ENV['SITE'] || ENV['site']
require 'productize'

# Environment-specific configuration.
require_dependency "environments/#{RAILS_ENV}"
ActiveRecord::Base.configurations = YAML::load(ERB.new((IO.read("#{RAILS_ROOT}/config/database.yml"))).result)
ActiveRecord::Base.establish_connection


# Configure defaults if the included environment did not.
begin
  RAILS_DEFAULT_LOGGER = Logger.new("#{RAILS_ROOT}/log/#{RAILS_ENV}.log")
  RAILS_DEFAULT_LOGGER.level = (RAILS_ENV == 'production' ? Logger::INFO : Logger::DEBUG)
rescue StandardError
  RAILS_DEFAULT_LOGGER = Logger.new(STDERR)
  RAILS_DEFAULT_LOGGER.level = Logger::WARN
  RAILS_DEFAULT_LOGGER.warn(
    "Rails Error: Unable to access log file. Please ensure that log/#{RAILS_ENV}.log exists and is chmod 0666. " +
    "The log level has been raised to WARN and the output directed to STDERR until the problem is fixed."
  )
=======
  # See Rails::Configuration for more options
>>>>>>> .r3370
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

<<<<<<< .mine
# Set up routes.
ActionController::Routing::Routes.reload

Controllers = Dependencies::LoadingModule.root(
  File.join(RAILS_ROOT, 'app', 'controllers'),
  # Load site-specific controllers if we can't find a generic one first (order matters)
  File.join(SITE_ROOT, 'app', 'controllers'),
  File.join(RAILS_ROOT, 'components')
)

# Include your app's configuration here:

=======
# Include your application configuration below>>>>>>> .r3370
