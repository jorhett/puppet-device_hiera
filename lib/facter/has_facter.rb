# has_facter.rb
#
# Puppet Device does not use Facter, so there's no facterversion fact.
#
Facter.add('has_facter') do
  setcode do
    !Facter.value(:facterversion).nil?
  end
end

