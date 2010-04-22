require "rubygems"
require "spec"

gem "rack", "~> 1.0.0"

require "rack/test"

Spec::Runner.configure do |config|
  config.include Rack::Test::Methods
end

describe Rack::Test::Session do
  describe "initialization" do
    it "supports being initialized from an explicit config.ru path" do
      CONFIG_RU = File.dirname(__FILE__) + '/../../config.ru'
      session = Rack::Test::Session.new(app)
      session.request("/").should be_ok
    end
  end
end