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

#Install Ubuntu Server (12.04 - 64 bit) with SSH Server.
#sudo apt-get update
#sudo apt-get upgrade
#sudo apt-get dist-upgrade

#base packages
%w(git openssh-server dpkg-dev build-essential).each do |pkg|
  package pkg
  action :install
end

# install packages for compiling ruby
%w(libssl-dev libreadline-dev zlib1g-dev libyaml-dev libffi-dev).each do |pkg|
  package pkg
  action :install
end

# install packages for sqlite
%w(sqlite3 libsqlite3-dev).each do |pkg|
  package pkg
  action :install
end

# # install packages for passenger
%w(libcurl4-openssl-dev curl libxslt1-dev).each do |pkg|
  package pkg
  action :install
end

# Install libxslt1-dev for Ruby RDF (linkeddata)
%w(libxslt1-dev).each do |pkg|
  package pkg
  action :install
end

# Install packages for virtuoso
# sudo apt-get install autoconf automake libtool flex bison gperf gawk m4 make odbcinst libxml2-dev libssl-dev libreadline-dev
%w(autoconf automake libtool flex bison gperf gawk m4 make odbcinst libxml2-dev libssl-dev libreadline-dev).each do |pkg|
  package pkg
  action :install
end

# # Install packages for raptor-utils (ruby.rdf see rubygems.org:rdf and blog.datagraph.org/:parsing-rdf-with-ruby
%w(raptor-utils).each do |pkg|
  package pkg
  action :install
end

# Install Imagemagick if you want it for Ruby or Virtuoso
%w(imagemagick libmagickcore3-extra netpbm).each do |pkg|
  package pkg
  action :install
end

# # Install Ruby from source (Ruby1.9.3-p125)
# wget ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p125.tar.gz
remote_file "/tmp/ruby-1.9.3-p125.tar.gz" do
  source "ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p125.tar.gz"
  mode "0644"
  checksum "8b3c035cf4f0ad6420f447d6a48e8817e5384d0504514939aeb156e251d44cce"
end

script "install_ruby193-p125" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
  tar -zxf ruby-1.9.3-p125.tar.gz
  cd ruby-1.9.3-p125
  ./configure
  make
  make install
  EOH
end

# sudo gem update --system
# # Install gems
# sudo gem install sqlite3             	# Basic Database
gem_package 'sqlite'

# sudo gem install rails -v 2.3.8     	# Change for your version of Rails
gem_package("rails") do
  version "2.3.8"
  action :install
end

# sudo gem install passenger           	# For Passenger
# sudo gem install rdf rdf-raptor rdf-json rdf-trix sparql-client   # For Ruby RDF Gems
#gem_package 'rdf'
#gem_package 'rdf-raptor'
#gem_package 'rdf-json'
#gem_package 'rdf-trix'
#gem_package 'sparql-client'
%w(sqlite rdf rdf-raptor rdf-json rdf-trix sparql-client).each do |gem|
  gem_package gem
end

# cd .. # to get back to ~/src
# git clone https://github.com/openlink/virtuoso-opensource.git
# cd virtuoso-opensource-6.1.5
git "/tmp" do
  repository "https://github.com/openlink/virtuoso-opensource.git"
  reference "master"
  action :sync
end

# CFLAGS="-O2 -m64"
# export CFLAGS
#
# # Set configure note this makes isql-v rather than the package version name of isql-vt
# ./configure --prefix=/usr/local/ --with-readline --program-transform-name="s/isql/isql-vt/" 
# make
# sudo make install
script "install_virtuoso" do
  interpreter "bash"
  user "root"
  cwd "/tmp"
  code <<-EOH
  cd virtuoso-opensource
  CFLAGS="-O2 -m64"
  export CFLAGS
  ./autogen.sh --prefix=/usr/local/ --with-readline --program-transform-name="s/isql/isql-vt/" 
  make
  make install
  EOH
end

# # Make a backup of the default virtuoso.ini, edit it to your specifications (See http://.... for optimal configurations based on RAM memory)
#
# # If you have multiple drives you will get the best performance if you spread your stripe segments across multiple drives. By default your
#
# # database stripes will be in the same directory as the virtuoso.ini file
#
# cd /usr/local/var/lib/virtuoso/db/
#
# sudo cp virtuoso.ini virtuoso.bak2
#
# sudo vi virtuoso.ini
#
# # Change the permissions so you can run virtuoso as a not root user
#
# cd /usr/local/var/lib/virtuoso/
#
# sudo chown -R yourlogin db
#
# sudo chown -R yourlogin db
#
# # Start Virtuoso
#
# cd /usr/local/var/lib/virtuoso/db/
#
# virtuoso-t -d     #debug mode, will quit when you log out
#
# virtuoso-t -f &   #persist after logout
#
# # Log into the Web-based conductor interface http://yourip:8890/conductor, choose "System Admin" => "User Accounts"
#
# # change the default passwords for the dba and dav accounts
#
# # Install the VAD packages choose "System Admin" => "Packages"
#
#   Framework
#
#     fct
#
#       isparql
#
#         rdf-mappers
#
#         # If you want to run the sparql interface on a different port than conductor see the page below page
#
#         # Note that isparql, fct will still run on the same interface as conductor.
#
#         # The SPARQL port is manly for services that access sparql directly, humans might prefer isparql
#
#         http://virtuoso.openlinksw.com/dataspace/dav/wiki/Main/VirtTipsAndTricksSPARQLCondPort
#
#

