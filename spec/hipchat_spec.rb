require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe HipChat do
  subject { HipChat::Client.new("blah") }

  let(:room) { subject["Hipchat"] }
  let (:url) { 'https://api.hipchat.com/v1/rooms/message?auth_token=blah' }
  
   before do
    stub_request(:post, url).to_return(:status => 200)
  end

  describe "configuration" do
    it "should be configurable to use EM::Http" do
      client = HipChat::Client.new("blah", :adapter => :em_http)
      client["Hipchat"].send("Dude", "Hello world").should be_true
    end

    it "should be configurable to log to stdout" do
      client = HipChat::Client.new("blah", :logging => true)
      client["Hipchat"].send("Dude", "Hello world").should be_true
    end
  end

  describe "rooms" do
    before do
      @stub = stub_request(:get, 'https://api.hipchat.com/v1/rooms/list?auth_token=blah').to_return(:status => 200, :body => '{"rooms" : [{"room_id" : "my_room"}]}')
    end

    it "should request a list of rooms" do
      subject.rooms
      @stub.should have_been_requested
    end

    it "should return a list of rooms" do
      subject.rooms.first.class.should == HipChat::Room
    end

    it "should be able to use the room id to send message" do
      subject.rooms.first.send("Dude", "Hello world").should be_true
      WebMock.should have_requested(:post, url).with(:body => hash_including(:room_id => 'my_room'))
    end
  end

  describe "sends a message to a room" do
    it "successfully without custom options" do
      room.send("Dude", "Hello world").should be_true
      WebMock.should have_requested(:post, url)
    end
    
    it "successfully with notifications on as boolean" do
      room.send("Dude", "Hello world", true).should be_true
      WebMock.should have_requested(:post, url).with(:body => hash_including(:notify => '1'))
    end
    
    it "successfully with notifications off as boolean" do
      room.send("Dude", "Hello world", :notify => false).should be_true
      WebMock.should have_requested(:post, url).with(:body => hash_including(:notify => '0'))
    end
    
    it "successfully with notifications on as option" do
      room.send("Dude", "Hello world", :notify => true).should be_true
      WebMock.should have_requested(:post, url).with(:body => hash_including(:notify => '1'))
    end
    
    it "successfully with custom color" do
      room.send("Dude", "Hello world", :color => 'red').should be_true
      WebMock.should have_requested(:post, url).with(:body => hash_including(:color => 'red'))
    end
    
    it "but fails when the room doesn't exist" do
      stub_request(:post, url).to_return(:status => 404)
      lambda { room.send "", "" }.should raise_error(HipChat::UnknownRoom)
    end

    it "but fails when we're not allowed to do so" do
      stub_request(:post, url).to_return(:status => 401)
      lambda { room.send "", "" }.should raise_error(HipChat::Unauthorized)
    end

    it "but fails if we get an unknown response code" do
      stub_request(:post, url).to_return(:status => 403)
      lambda { room.send "", "" }.
        should raise_error(HipChat::UnknownResponseCode)
    end
  end

end
