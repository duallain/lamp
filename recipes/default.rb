#
# Cookbook Name:: cmd_lamp
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

recipes = [
	"apt",
	"build-essential",
	"git",
	"php",
	"apache2",
	"apache2::mod_php5",
	"apache2::mod_rewrite",
	"mysql::server",
	"composer",
	"nodejs::install_from_source",
]

for r in recipes do
  include_recipe r
end

include_recipe "chef-composer"

# Install packages and software

packages = [
	"nano",
	"php5-curl",
	"php5-mcrypt",
	"php5-mysql",
	"php5-gd",
	"php5-imagick",
	"php-apc",
	"sendmail",
]

for p in packages do
  package p do
    action [:install]
  end
end

execute "gem install compass" do
  command "gem install compass"
  action :run
end

execute "npm install grunt" do
  command "npm install -g grunt-cli"
  action :run
end

execute "npm install forever" do
  command "npm install -g forever"
  action :run
end

# Add templates and fix permissions

template "/usr/local/bin/devadd" do
  source "devadd.erb"
  owner "root"
  group "staff"
  mode "0755"
end

template "/usr/local/bin/chweb" do
  source "chweb.erb"
  owner "root"
  group "staff"
  mode "0755"
end

execute "web permissions" do
  command "chown -R root:www-data /var/www && chmod 2775 /var/www"
  action :run
end

directory "/etc/php5/apache2" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

template "/etc/php5/apache2/php.ini" do
  source "php.ini-dev.erb"
  owner "root"
  group "root"
  mode "0644"
end

# Create virtual hosts

sites = data_bag("sites")

sites.each do |s|
	site = data_bag_item("sites", s)
	web_app site["id"] do
		template "site.conf.erb"
	  server_name site["id"]
	  docroot "/var/www/" + site["dir"]
	end
end