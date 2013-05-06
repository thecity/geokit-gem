require File.join(File.dirname(__FILE__), 'test_base_geocoder')

Geokit::Geocoders::geocoder_ca = "SOMEKEYVALUE"

class CaGeocoderTest < BaseGeocoderTest #:nodoc: all

  CA_SUCCESS=<<-EOF
  <?xml version="1.0" encoding="UTF-8" ?>
  <geodata><latt>49.243086</latt><longt>-123.153684</longt></geodata>
  EOF

  def setup
    @ca_full_hash = {:street_address=>"1160 West Georgia Street",:city=>"Vancouver", :state=>"BC", :zip=>"V6E3H7"}
    @ca_full_loc = Geokit::GeoLoc.new(@ca_full_hash)
  end

  def test_geocoder_with_geo_loc_with_account
    response = MockSuccess.new
    response.expects(:body).returns(CA_SUCCESS)
    url = "http://geocoder.ca/?locate=1160+West+Georgia+Street+BC+V6E3H7&auth=SOMEKEYVALUE&geoit=xml"
    Geokit::Geocoders::CaGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    #puts Geokit::Geocoders::CaGeocoder.geocode(@ca_full_loc)
    verify(Geokit::Geocoders::CaGeocoder.geocode(@ca_full_loc))
  end

  def test_service_unavailable
    response = MockFailure.new
    #Net::HTTP.expects(:get_response).with(URI.parse("http://geocoder.ca/?stno=2105&addresst=West+32nd+Avenue&city=Vancouver&prov=BC&auth=SOMEKEYVALUE&geoit=xml")).returns(response)
    url = "http://geocoder.ca/?locate=1160+West+Georgia+Street+BC+V6E3H7&auth=SOMEKEYVALUE&geoit=xml"
    Geokit::Geocoders::CaGeocoder.expects(:call_geocoder_service).with(url).returns(response)
    assert !Geokit::Geocoders::CaGeocoder.geocode(@ca_full_loc).success
  end

  private

  def verify(location)
    assert_equal "1160 West Georgia Street", location.street_address
    assert_equal "BC", location.state
    assert_equal "Vancouver", location.city
    assert_equal "V6E3H7", location.zip
    assert_equal "49.243086,-123.153684", location.ll
    assert !location.is_us?
  end
end
