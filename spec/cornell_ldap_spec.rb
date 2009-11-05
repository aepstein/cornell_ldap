require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'cornell_ldap'

ActiveLdap::Base.setup_connection :host => 'directory.cornell.edu',
                                  :port => 389,
                                  :base => 'o=Cornell University,c=US'


describe "CornellLdap" do
  before(:all) do
    @map = [
      ['staff', nil, nil, nil, 'staff'],
      ['academic', nil, 'Professor', nil, 'faculty'],
      ['academic', nil, nil, 'Prof Asst', 'faculty'],
      ['academic', nil, 'Librarian', nil, 'staff'],
      ['student', 'AS', nil, nil, 'undergrad'],
      ['student', 'GR', nil, nil, 'grad'],
      ['alumni', nil, nil, nil, 'alumni'],
      ['temp', nil, nil, nil, 'temporary'],
      ['blah', nil, nil, nil, 'unknown']
    ]
  end

  before(:each) do
  end

  it "should correctly guess the status of several types" do
    @map.each do |scenario|
      person = mock_person
      person.attributes={
        'type' => scenario[0],
        'cornelleduacadcollege' => scenario[1],
        'cornelleduwrkngtitle1' => scenario[2],
        'cornelleduwrkngtitle2' => scenario[3]
      }
      person.status.should eql scenario[4]
      person
    end
  end

  it "should return appropriate name attributes" do
    person = mock_person
    person.first_name.should eql 'John'
    person.middle_name.should eql 'A'
    person.last_name.should eql 'Doe'
  end

  it "should correctly parse addresses" do
    [
      [ '1 Main St., Apt 1, Ithaca, NY, 14850',
        { :street => '1 Main St., Apt 1', :city => 'Ithaca', :state => 'NY',
          :zip => '14850' } ]
    ].each do |scenario|
      result = CornellLdap::Record.address_attributes(scenario[0])
      scenario[1].each do |key, value|
        result[key].should eql value
      end
    end
  end

  def mock_person
    person = CornellLdap::Record.new
    person.attributes={
      'type' => 'staff',
      'cornelleduacadcollege' => 'AS',
      'cornelleducampusaddress' => '-100 Day Hall',
      'cornelledulocaladdress' => '1 Main St., Apt. 1, Ithaca, NY, 14850',
      'homePostalAddress' => '1 Broadway, New York, NY, 00000',
      'givenName' => 'John',
      'cornelledumiddlename' => 'A',
      'sn' => 'Doe'
    }
    person
  end
end

