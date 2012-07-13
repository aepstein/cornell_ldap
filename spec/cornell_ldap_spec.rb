require 'spec_helper'
require 'cornell_ldap'

CornellLdap::Record.setup_connection :host => 'directory.cornell.edu',
  :port => 389, :base => 'o=Cornell University,c=US'


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
      ['blah', nil, nil, nil, false]
    ]
  end

  before(:each) do
  end

  it "should correctly guess the status of several types" do
    @map.each do |scenario|
      person = mock_person( {
        :cornelledutype => [scenario[0]],
        :cornelleduacadcollege => [scenario[1]],
        :cornelleduwrkngtitle1 => [scenario[2]],
        :cornelleduwrkngtitle2 => [scenario[3]]
      } )
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

  it "should call address_attributes to return local address" do
    person = mock_person
    CornellLdap::Record.should_receive(:address_attributes).once.with(person.attributes[:local_address])
    person.local_address
  end

  it "should call address_attributes to return home address" do
    person = mock_person
    CornellLdap::Record.should_receive(:address_attributes).once.with(person.attributes[:home_address])
    person.home_address
  end

  it "should strip whitespace from campus address" do
    person = mock_person
    person.campus_address[:street].should eql '-100 Day Hall'
  end

  it "should strip non-numeric values from phone numbers" do
    person = mock_person
    person.campus_phone.should eql '6075551212'
    person.local_phone.should eql '6075551212'
    person.home_phone.should eql '6075551212'
    person.mobile_phone.should eql '6075551212'
  end

  def mock_person(values = {})
    CornellLdap::Record.new( {
      :cornelledutype => ['staff'],
      :cornelleduacadcollege => ['AS'],
      :cornelleducampusaddress => ['-100 Day Hall     '],
      :cornelledulocaladdress => ['1 Main St., Apt. 1, Ithaca, NY, 14850'],
      :homepostaladdress => ['1 Broadway, New York, NY, 00000'],
      :givenname => ['John'],
      :cornelledumiddlename => ['A'],
      :sn => ['Doe'],
      :cornelleducampusphone => ['607+555-1212'],
      :homephone => ['607-555*1212'],
      :cornelledulocalphone => ['607-555 1212'],
      :mobile => ['607 555 1212']
    }.merge(values) )
  end
end

