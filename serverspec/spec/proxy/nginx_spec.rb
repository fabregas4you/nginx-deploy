require 'spec_helper'

if os[:family] == 'Redhat'
  nginx_package = 'nginx'
elsif os[:family] == 'Debian' || os[:family] == 'Ubuntu'
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
