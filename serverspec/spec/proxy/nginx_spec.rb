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

# check: httpd up
# describe service(httpd_package) do
#   it { should be_enabled }
# end

# check: deamon port
# describe port(80) do
#   it { should be_listening.with('tcp') }
# end

# check: deamon port
# describe port(443) do
#   it { should be_listening.with('tcp') }
# end

# check: certs
# describe x509_certificate('some_cert.pem') do
#    it { should be_valid }
# end

## test
describe file('/etc/httpd/conf/httpd.conf') do
  it { should be_file }
end
