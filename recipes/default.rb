## Author::  Phil Cryer (<pcryer@mbl.edu>)
## Cookbook Name:: virtuoso
## Recipe:: default
##
## Copyright 2012, Woods Hole Marine Biological Laboratory
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
##




%w(git openssh-server dpkg-dev build-essential).each do |pkg|
  package pkg
end

# install packages for compiling ruby
%w(libssl-dev libreadline-dev zlib1g-dev libyaml-dev libffi-dev).each do |pkg|
  package pkg
end

# install packages for sqlite
%w(sqlite3 libsqlite3-dev).each do |pkg|
  package pkg
end

# # install packages for passenger
%w(libcurl4-openssl-dev curl libxslt1-dev).each do |pkg|
  package pkg
end

# Install libxslt1-dev for Ruby RDF (linkeddata)
%w(libxslt1-dev).each do |pkg|
  package pkg
end

# Install packages for virtuoso
# sudo apt-get install autoconf automake libtool flex bison gperf gawk m4 make odbcinst libxml2-dev libssl-dev libreadline-dev
%w(autoconf automake libtool flex bison gperf gawk m4 make odbcinst libxml2-dev libssl-dev libreadline-dev).each do |pkg|
  package pkg
end

# # Install packages for raptor-utils (ruby.rdf see rubygems.org:rdf and blog.datagraph.org/:parsing-rdf-with-ruby
%w(raptor-utils).each do |pkg|
  package pkg
end
# Install Imagemagick if you want it for Ruby or Virtuoso
%w(imagemagick libmagickcore4-extra netpbm).each do |pkg|
  package pkg
end



#install gem dependencies
# rails needs a specific version (2.3.8) # Change for your version of Rails
gem_package("rails") do
  version "2.3.8"
  action :install
end


# install RDF gems
%w(rdf rdf-raptor rdf-json rdf-trix sparql-client).each do |gem|
  gem_package gem
end

user "virtuoso" do
  comment "virtuoso user"
  system true
  shell "/bin/false"
end


git "/tmp/virtuoso-opensource" do
  repository "https://github.com/openlink/virtuoso-opensource.git"
  reference "master"
  action :sync
  user "virtuoso"                                    
  group "virtuoso"    
  notifies :run, 'script[install_virtuoso]', :immediately
end

# CFLAGS="-O2 -m64"
# export CFLAGS
#
# # Set configure note this makes isql-v rather than the package version name of isql-vt
# ./configure --prefix=/usr/local/ --with-readline --program-transform-name="s/isql/isql-vt/" 
  #git clone https://github.com/openlink/virtuoso-opensource.git
# make
# sudo make install
script "install_virtuoso" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
  cd /tmp/virtuoso-opensource
  CFLAGS="-O2 -m64"
  export CFLAGS
  ./autogen.sh --enable-maintainer-mode --prefix=/usr/local/ --with-readline --program-transform-name="s/isql/isql-vt/" 
  ./configure --prefix=/usr/local/ --with-readline --program-transform-name="s/isql/isql-vt/" 
  make
  make install
  #startup as root user to finish install, then shutdown
  cd /usr/local/var/lib/virtuoso/db
  virtuoso-t -d &
  sleep 15
  killall virtuoso-t
  EOH
  not_if do
	File.exists?("/usr/local/bin/virtuoso-t")
  end
end

template "/etc/init.d/virtuoso" do
	mode "0755" 
	source "init.erb"
end

service "virtuoso" do
	supports [ :stop, :start, :restart ]
	action [ :enable, :start ]
end
