require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'
require 'rake/contrib/rubyforgepublisher'

require 'date'
require 'rbconfig'

require File.join(File.dirname(__FILE__), 'lib', 'rails_version')

PKG_BUILD       = ENV['PKG_BUILD'] ? '.' + ENV['PKG_BUILD'] : ''
PKG_NAME        = 'rails_product'
PKG_VERSION     = '0.7' + PKG_BUILD
PKG_FILE_NAME   = "#{PKG_NAME}-#{PKG_VERSION}"
PKG_DESTINATION = ENV["RAILS_PKG_DESTINATION"] || "../#{PKG_NAME}"

RELEASE_NAME  = "REL #{PKG_VERSION}"

RUBY_FORGE_PROJECT = "rails"
RUBY_FORGE_USER    = "webster132"


# Rake::TestTask.new("test") do |t|
#   t.libs << 'test'
#   t.pattern = 'test/*_test.rb'
#   t.verbose = true
# end


BASE_DIRS   = %w( app config/environments components db doc log lib lib/tasks public script script/performance script/process test vendor vendor/plugins )
APP_DIRS    = %w( models controllers helpers views views/layouts )
PUBLIC_DIRS = %w( images javascripts stylesheets )
TEST_DIRS   = %w( fixtures unit functional mocks mocks/development mocks/test )

BASE_DIRS << "sites"
SITE_BASE_DIRS = %w( app db db/migrate public test )
SITE_APP_DIRS = %w( models controllers helpers views views/layouts )
SITE_TEST_DIRS = %w( fixtures unit functional )

LOG_FILES    = %w( server.log development.log test.log production.log )
HTML_FILES   = %w( 404.html 500.html index.html robots.txt favicon.ico images/rails.png
                   javascripts/prototype.js
                   javascripts/effects.js javascripts/dragdrop.js javascripts/controls.js )
BIN_FILES    = %w( about breakpointer console destroy generate performance/benchmarker performance/profiler process/reaper process/spawner process/spinner runner server plugin )

VENDOR_LIBS = %w( actionpack activerecord actionmailer activesupport actionwebservice railties )


desc "Generates a fresh Rails package with documentation"
task :fresh_rails => [ :clean, :make_dir_structure, :initialize_file_stubs, :copy_vendor_libraries, :copy_ties_content, :generate_documentation ]

desc "Generates a fresh Rails package using GEMs with documentation"
task :fresh_gem_rails => [ :clean, :make_dir_structure, :initialize_file_stubs, :copy_ties_content, :copy_gem_environment ]

desc "Generates a fresh Rails package without documentation (faster)"
task :fresh_rails_without_docs => [ :clean, :make_dir_structure, :initialize_file_stubs, :copy_vendor_libraries, :copy_ties_content ]

desc "Generates a fresh Rails package without documentation (faster)"
task :fresh_rails_without_docs_using_links => [ :clean, :make_dir_structure, :initialize_file_stubs, :link_vendor_libraries, :copy_ties_content ]

desc "Generates minimal Rails package using symlinks"
task :dev => [ :clean, :make_dir_structure, :initialize_file_stubs, :link_vendor_libraries, :copy_ties_content ]

desc "Packages the fresh Rails package with documentation"
task :package => [ :clean, :fresh_rails ] do
  system %{cd ..; tar -czvf #{PKG_NAME}-#{PKG_VERSION}.tgz #{PKG_NAME}}
  system %{cd ..; zip -r #{PKG_NAME}-#{PKG_VERSION}.zip #{PKG_NAME}}
end

task :clean do
  rm_rf PKG_DESTINATION
end

# Get external spinoffs -------------------------------------------------------------------

desc "Updates railties to the latest version of the javascript spinoffs"
task :update_js do
  for js in %w( prototype controls dragdrop effects slider )
    rm "html/javascripts/#{js}.js"
    cp "./../actionpack/lib/action_view/helpers/javascripts/#{js}.js", "html/javascripts"
  end
end

# Make directory structure ----------------------------------------------------------------

def make_dest_dirs(dirs, path = nil)
  mkdir_p dirs.map { |dir| File.join(PKG_DESTINATION, path, dir) }
end

desc "Make the directory structure for the new Rails application"
task :make_dir_structure => [ :make_base_dirs, :make_app_dirs, :make_public_dirs, :make_test_dirs ]

task(:make_base_dirs)   { make_dest_dirs BASE_DIRS              }
task(:make_app_dirs)    { make_dest_dirs APP_DIRS,    'app'     }
task(:make_public_dirs) { make_dest_dirs PUBLIC_DIRS, 'public'  }
task(:make_test_dirs)   { make_dest_dirs TEST_DIRS,   'test'    }


# Initialize file stubs -------------------------------------------------------------------

desc "Initialize empty file stubs (such as for logging)"
task :initialize_file_stubs => [ :initialize_log_files ]

task :initialize_log_files do
  log_dir = File.join(PKG_DESTINATION, 'log')
  chmod 0777, log_dir
  LOG_FILES.each do |log_file|
    log_path = File.join(log_dir, log_file)
    touch log_path
    chmod 0666, log_path
  end
end


# Copy Vendors ----------------------------------------------------------------------------

desc "Copy in all the Rails packages to vendor"
task :copy_vendor_libraries do
  mkdir File.join(PKG_DESTINATION, 'vendor', 'rails')
  VENDOR_LIBS.each { |dir| cp_r File.join('..', dir), File.join(PKG_DESTINATION, 'vendor', 'rails', dir) }
end

desc "Link in all the Rails packages to vendor"
task :link_vendor_libraries do
  mkdir File.join(PKG_DESTINATION, 'vendor', 'rails')
  VENDOR_LIBS.each { |dir| ln_s File.join('..', '..', '..', dir), File.join(PKG_DESTINATION, 'vendor', 'rails', dir) }
end


# Copy Ties Content -----------------------------------------------------------------------

# :link_apache_config
desc "Make copies of all the default content of ties"
task :copy_ties_content => [ 
  :copy_rootfiles, :copy_dispatches, :copy_html_files, :copy_application,
  :copy_configs, :copy_binfiles, :copy_test_helpers, :copy_app_doc_readme ]

task :copy_dispatches do
  copy_with_rewritten_ruby_path("dispatches/dispatch.rb", "#{PKG_DESTINATION}/public/dispatch.rb")
  chmod 0755, "#{PKG_DESTINATION}/public/dispatch.rb"

  copy_with_rewritten_ruby_path("dispatches/dispatch.rb", "#{PKG_DESTINATION}/public/dispatch.cgi")
  chmod 0755, "#{PKG_DESTINATION}/public/dispatch.cgi"

  copy_with_rewritten_ruby_path("dispatches/dispatch.fcgi", "#{PKG_DESTINATION}/public/dispatch.fcgi")
  chmod 0755, "#{PKG_DESTINATION}/public/dispatch.fcgi"

  # copy_with_rewritten_ruby_path("dispatches/gateway.cgi", "#{PKG_DESTINATION}/public/gateway.cgi")
  # chmod 0755, "#{PKG_DESTINATION}/public/gateway.cgi"
end

task :copy_html_files do
  HTML_FILES.each { |file| cp File.join('html', file), File.join(PKG_DESTINATION, 'public', file) }
end

task :copy_application do
  cp "helpers/application.rb", "#{PKG_DESTINATION}/app/controllers/application.rb"
  cp "helpers/application_helper.rb", "#{PKG_DESTINATION}/app/helpers/application_helper.rb"
end

task :copy_configs do
  app_name = "rails"
  socket = nil
  require 'erb'
  File.open("#{PKG_DESTINATION}/config/database.yml", 'w') {|f| f.write ERB.new(IO.read("configs/database.yml"), nil, '-').result(binding)}
  
  cp "configs/routes.rb", "#{PKG_DESTINATION}/config/routes.rb"

  cp "configs/apache.conf", "#{PKG_DESTINATION}/public/.htaccess"

  cp "environments/boot.rb", "#{PKG_DESTINATION}/config/boot.rb"
  cp "environments/environment.rb", "#{PKG_DESTINATION}/config/environment.rb"
  cp "environments/production.rb", "#{PKG_DESTINATION}/config/environments/production.rb"
  cp "environments/development.rb", "#{PKG_DESTINATION}/config/environments/development.rb"
  cp "environments/test.rb", "#{PKG_DESTINATION}/config/environments/test.rb"
end

task :copy_binfiles do
  BIN_FILES.each do |file|
    dest_file = File.join(PKG_DESTINATION, 'script', file)
    copy_with_rewritten_ruby_path(File.join('bin', file), dest_file)
    chmod 0755, dest_file
  end
end

task :copy_rootfiles do
  cp "fresh_rakefile", "#{PKG_DESTINATION}/Rakefile"
  cp "README", "#{PKG_DESTINATION}/README"
  cp "CHANGELOG", "#{PKG_DESTINATION}/CHANGELOG"
end

task :copy_test_helpers do
  cp "helpers/test_helper.rb", "#{PKG_DESTINATION}/test/test_helper.rb"
end

task :copy_app_doc_readme do
  cp "doc/README_FOR_APP", "#{PKG_DESTINATION}/doc/README_FOR_APP"
end

task :link_apache_config do
  chdir(File.join(PKG_DESTINATION, 'config')) {
    ln_s "../public/.htaccess", "apache.conf"
  }
end

def copy_with_rewritten_ruby_path(src_file, dest_file)
  ruby = File.join(Config::CONFIG['bindir'], Config::CONFIG['ruby_install_name'])

  File.open(dest_file, 'w') do |df|
    File.open(src_file) do |sf|
      line = sf.gets
      if (line =~ /#!.+ruby\s*/) != nil
        df.puts("#!#{ruby}")
      else
        df.puts(line)
      end
      df.write(sf.read)
    end
  end
end


# Generate documentation ------------------------------------------------------------------

desc "Generate documentation for the framework and for the empty application"
task :generate_documentation => [ :generate_app_doc, :generate_rails_framework_doc ]

task :generate_rails_framework_doc do
  system %{cd #{PKG_DESTINATION}; rake apidoc}
end

task :generate_app_doc do
  File.cp "doc/README_FOR_APP", "#{PKG_DESTINATION}/doc/README_FOR_APP"
  system %{cd #{PKG_DESTINATION}; rake appdoc}
end

Rake::RDocTask.new { |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = "Railties -- Gluing the Engine to the Rails"
  rdoc.options << '--line-numbers --inline-source --accessor cattr_accessor=object'
  rdoc.template = "#{ENV['template']}.rb" if ENV['template']
  rdoc.rdoc_files.include('README', 'CHANGELOG')
  rdoc.rdoc_files.include('lib/*.rb')
  rdoc.rdoc_files.include('lib/rails_generator/*.rb')
  rdoc.rdoc_files.include('lib/commands/**/*.rb')
}

# Generate GEM ----------------------------------------------------------------------------

task :copy_gem_environment do
  cp "environments/environment.rb", "#{PKG_DESTINATION}/config/environment.rb"
  chmod 0755, dest_file
end


PKG_FILES = FileList[
  '[a-zA-Z]*',
  'bin/**/*', 
  'builtin/**/*',
  'configs/**/*', 
  'doc/**/*', 
  'dispatches/**/*', 
  'environments/**/*', 
  'helpers/**/*', 
  'generators/**/*', 
  'html/**/*', 
  'lib/**/*',
  'sites/**/*'
]

spec = Gem::Specification.new do |s|
  s.name = 'rails_product'
  s.version = PKG_VERSION
  s.summary = "Creates a ready-to-go productized Ruby on Rails application from a single command ('rails_product')."
  s.description = <<-EOF
    A "Productized Rails Application" is a single generic application having a hierarchical structure
wherein add-ons and tweaks for concurrent versions of the application are possible without affecting
the core "generic" code base.  You might use this, for example, if you want to maintain a common
shopping cart code base that all of your clients use, while still providing flexibility for paid
add-ons or site-specific needs.
  EOF

  s.add_dependency('rake', '>= 0.6.2')
  s.add_dependency('activesupport',    '= 1.2.3' + PKG_BUILD)
  s.add_dependency('activerecord',     '= 1.13.0' + PKG_BUILD)
  s.add_dependency('actionpack',       '= 1.11.0' + PKG_BUILD)
  s.add_dependency('actionmailer',     '= 1.1.3' + PKG_BUILD)
  s.add_dependency('actionwebservice', '= 0.9.3' + PKG_BUILD)

  s.rdoc_options << '--exclude' << '.'
  s.has_rdoc = false

  s.files = PKG_FILES.to_a.delete_if {|f| f.include?('.svn')}
  s.require_path = 'lib'

  s.bindir = "bin"                               # Use these for applications.
  s.executables = ["rails_product"]
  s.default_executable = "rails_product"

  s.author = "Duane Johnson"
  s.email = "duane.johnson@gmail.com"
  s.homepage = "http://inquirylabs.com/productize/"
  s.rubyforge_project = "rails_product"
end

Rake::GemPackageTask.new(spec) do |pkg|
end


# Publishing -------------------------------------------------------
desc "Publish the API documentation"
task :pgem => [:gem] do 
  Rake::SshFilePublisher.new("davidhh@wrath.rubyonrails.org", "public_html/gems/gems", "pkg", "#{PKG_FILE_NAME}.gem").upload
  `ssh davidhh@wrath.rubyonrails.org './gemupdate.sh'`
end

desc "Publish the release files to RubyForge."
task :release => [:gem] do
  files = ["gem"].map { |ext| "pkg/#{PKG_FILE_NAME}.#{ext}" }

  if RUBY_FORGE_PROJECT then
    require 'net/http'
    require 'open-uri'

    project_uri = "http://rubyforge.org/projects/#{RUBY_FORGE_PROJECT}/"
    project_data = open(project_uri) { |data| data.read }
    group_id = project_data[/[?&]group_id=(\d+)/, 1]
    raise "Couldn't get group id" unless group_id

    # This echos password to shell which is a bit sucky
    if ENV["RUBY_FORGE_PASSWORD"]
      password = ENV["RUBY_FORGE_PASSWORD"]
    else
      print "#{RUBY_FORGE_USER}@rubyforge.org's password: "
      password = STDIN.gets.chomp
    end

    login_response = Net::HTTP.start("rubyforge.org", 80) do |http|
      data = [
        "login=1",
        "form_loginname=#{RUBY_FORGE_USER}",
        "form_pw=#{password}"
      ].join("&")
      http.post("/account/login.php", data)
    end

    cookie = login_response["set-cookie"]
    raise "Login failed" unless cookie
    headers = { "Cookie" => cookie }

    release_uri = "http://rubyforge.org/frs/admin/?group_id=#{group_id}"
    release_data = open(release_uri, headers) { |data| data.read }
    package_id = release_data[/[?&]package_id=(\d+)/, 1]
    raise "Couldn't get package id" unless package_id

    first_file = true
    release_id = ""

    files.each do |filename|
      basename  = File.basename(filename)
      file_ext  = File.extname(filename)
      file_data = File.open(filename, "rb") { |file| file.read }

      puts "Releasing #{basename}..."

      release_response = Net::HTTP.start("rubyforge.org", 80) do |http|
        release_date = Time.now.strftime("%Y-%m-%d %H:%M")
        type_map = {
          ".zip"    => "3000",
          ".tgz"    => "3110",
          ".gz"     => "3110",
          ".gem"    => "1400"
        }; type_map.default = "9999"
        type = type_map[file_ext]
        boundary = "rubyqMY6QN9bp6e4kS21H4y0zxcvoor"

        query_hash = if first_file then
          {
            "group_id" => group_id,
            "package_id" => package_id,
            "release_name" => RELEASE_NAME,
            "release_date" => release_date,
            "type_id" => type,
            "processor_id" => "8000", # Any
            "release_notes" => "",
            "release_changes" => "",
            "preformatted" => "1",
            "submit" => "1"
          }
        else
          {
            "group_id" => group_id,
            "release_id" => release_id,
            "package_id" => package_id,
            "step2" => "1",
            "type_id" => type,
            "processor_id" => "8000", # Any
            "submit" => "Add This File"
          }
        end

        query = "?" + query_hash.map do |(name, value)|
          [name, URI.encode(value)].join("=")
        end.join("&")

        data = [
          "--" + boundary,
          "Content-Disposition: form-data; name=\"userfile\"; filename=\"#{basename}\"",
          "Content-Type: application/octet-stream",
          "Content-Transfer-Encoding: binary",
          "", file_data, ""
          ].join("\x0D\x0A")

        release_headers = headers.merge(
          "Content-Type" => "multipart/form-data; boundary=#{boundary}"
        )

        target = first_file ? "/frs/admin/qrs.php" : "/frs/admin/editrelease.php"
        http.post(target + query, data, release_headers)
      end

      if first_file then
        release_id = release_response.body[/release_id=(\d+)/, 1]
        raise("Couldn't get release id") unless release_id
      end

      first_file = false
    end
  end
end
