# taken from: http://nuknad.com/2011/02/11/self-classifying-puppet-nodes/
#
# The following is a facter plugin that will parse the file /etc/vagrant.facts and append them to the existing facts.
# Given the following facts file:
#
# root_password=YYY
# foo=bar
#
# We will get the following from facter:
#
# vagrant_root_password = YYY
# vagrant_foo = bar
#
require 'facter'

if File.exist?("/etc/vagrant.facts")
    File.readlines("/etc/vagrant.facts").each do |line|
        if line =~ /^(.+)=(.+)$/
            var = "vagrant_"+$1.strip;
            val = $2.strip

            Facter.add(var) do
                setcode { val }
            end
        end
    end
end

