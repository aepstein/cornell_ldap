require 'rubygems' unless defined? Gem
require 'net/ldap' unless defined? Net::LDAP

module CornellLdap
  class Record < Object

    MAPPINGS = {
      :cornelledutype          => :status,
      :cornelleduwrkngtitle1   => :status_title1,
      :cornelleduwrkngtitle2   => :status_title2,
      :cornelleduacadcollege   => :college,
      :cornelleducampusaddress => :campus_address,
      :cornelledulocaladdress  => :local_address,
      :homepostaladdress       => :home_address,
      :givenname               => :first_name,
      :cornelledumiddlename    => :middle_name,
      :sn                      => :last_name
    }

    CONNECTION_PARAMETERS = [ :port, :host, :auth ]

    def self.setup_connection( params )
      @@connection_params = params.inject({}) do |memo, (k, v)|
        memo[k.to_sym] = v
        memo
      end
      @@connection = Net::LDAP.new(
        @@connection_params.inject({}) do |memo, (k, v)|
          memo[k] = v if CONNECTION_PARAMETERS.include? k
          memo
        end
      )
    end

    def self.connection
      @@connection
    end

    def self.find( subject )
      r = connection.search(
        :base => 'ou=People,' + @@connection_params[:base], :size => 1,
        :filter => Net::LDAP::Filter.eq( 'uid', subject ),
        :scope => Net::LDAP::SearchScope_SingleLevel
      )
      return CornellLdap::Record.new( r.first ) if r && r.length > 0
      nil
    end

    # Takes an address string and converts it to a hash representation:
    #
    # [street] Street address
    # [city]   City
    # [state]  State
    # [zip]    Zip code
    def self.address_attributes(string_address)
      return if string_address.nil?
      array_address = string_address.split(',').map! { |x| x.strip }
      state = false
      array_address.each_index { |i| state = i if array_address[i] =~ /^[A-Za-z]{2,2}$/ }
      return unless state && state > 1
      attributes = { :street => array_address[0..(state-2)].join(', '),
        :city => array_address[state - 1],
        :state => array_address[state] }
      attributes[:zip] = array_address[state + 1] unless array_address[state + 1].nil?
      attributes
    end

    attr_accessor :attributes

    def initialize( record )
      self.attributes = Hash.new
      MAPPINGS.each do |ldap, local|
        self.attributes[local] = record[ldap].first unless record[ldap].nil? || record[ldap].empty?
      end
    end

    # Returns a string representation of the person's status with the university
    # of one of the following types:
    #
    # [staff]     non-faculty employee
    # [faculty]   tenured or tenure-track faculty
    # [undergrad] undergraduate student
    # [grad]      graduate or professional student
    # [alumni]    alumnus
    # [temporary] temporary or casual employee
    # false       status unknown
    def status
      return @status unless @status.nil?
      return unless attributes.key?( :status )
      @status = case attributes[:status]
        when /^staff/ then 'staff'
        when /^acad/ then
          if ( attributes.key?(:status_title1) && attributes[:status_title1] =~ /^Prof/ ) ||
             ( attributes.key?(:status_title2) && attributes[:status_title2] =~ /^Prof/ ) then
             'faculty'
          else
            'staff'
          end
        when /^student/ then case attributes[:college]
          when 'AS', 'AR', 'AG', 'IL', 'HE', 'EN', 'UN' then 'undergrad'
          else 'grad'
        end
        when /^alumni/ then 'alumni'
        when /^temp/ then 'temporary'
        else false
      end
    end

    # Returns has representation of on campus address for person if one is
    # reported.
    # See CornellLdap::Record#address_attributes for more information.
    def campus_address
      unless @campus_address.nil?
        return @campus_address
      end
      @campus_address = false unless attributes.key?(:campus_address) &&
        @campus_address = { :street => attributes[:campus_address].strip,
                            :on_campus => true }
      return campus_address
    end

    # Returns local area (Ithaca area) address for person if one is reported
    # See CornellLdap::Record#address_attributes for more information.
    def local_address
      unless @local_address.nil?
        return @local_address
      end
      @local_address = false unless attributes.key?(:local_address) &&
        @local_address = Record.address_attributes(attributes[:local_address])
      return local_address
    end

    # Returns home address for person if one is reported
    # See CornellLdap::Record#address_attributes for more information.
    def home_address
      unless @home_address.nil?
        return @home_address
      end
      @home_address = false unless attributes.key?(:home_address) &&
        @home_address = Record.address_attributes(attributes[:home_address])
      return home_address
    end

    # Returns first name of person
    def first_name; attributes[:first_name]; end

    # Returns middle name of person
    def middle_name; attributes[:middle_name]; end

    # Returns last name of person
    def last_name; attributes[:last_name]; end
  end
end

