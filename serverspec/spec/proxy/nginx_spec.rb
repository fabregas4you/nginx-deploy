require 'spec_helper'

if os[:family] == 'redhat'
  nginx_package = 'httpd'
elsif os[:family] == 'debian' || os[:family] == 'ubuntu'
  nginx_package = 'nginx'
end

# chech: nginx installed
describe package(nginx_package) do
  it { should be_installed }
end

# check: nginx up
describe service(nginx_package) do
  it { should be_enabled }
end
