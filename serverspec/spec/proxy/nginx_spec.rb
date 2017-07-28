require 'spec_helper'

# if os[:family] == 'Redhat'
#   httpd_package = 'httpd'
# elsif os[:family] == 'Debian' || os[:family] == 'Ubuntu'
#   httpd_package = 'httpd'
# end

# chech: httpd installed
# describe package(httpd_package) do
#   it { should be_installed }
# end
describe package('nginx') do
  it { should be_installed }
end

# check: httpd up
# describe service(httpd_package) do
#   it { should be_enabled }
# end

## check: deamon port
# PORTS=['80','443']
# PORTS.each do |port|
#   describe port("#{port}") do
#    it { should be_listening }
#   end
# end

## check: response TLS
# describe command('curl -sL -w "%{http_code}\\n" "www.example.com" -o /dev/null | sed "s/200/OK/" | sed "s/302/OK/"') do
#  its(:stdout) { should match 'OK' }
# end
describe command('curl -sL -w "%{http_code}\\n" -H"Host: azure.hi-ga.to" https://0.0.0.0:443 -k -o /dev/null | sed "s/200/OK/" | sed "s/302/OK/"') do
  its(:stdout) { should match 'OK' }
end

# check: certs
# describe x509_certificate('some_cert.pem') do
#    it { should be_valid }
# end

## test
describe file('/etc/httpd/conf/httpd.conf') do
  it { should be_file }
end
