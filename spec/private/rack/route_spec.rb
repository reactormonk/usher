require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "spec_helper"))
require "usher"

describe "Rack interface extensions for Usher::Route" do
  before(:each) do
    @route_set = Usher::Interface.for(:rack)
    @app = MockApp.new("Hello World!")
    @env = Rack::MockRequest.env_for("/index.html")
  end

  describe "basic functinality" do
    it "should set redirect headers" do
      @route_set.get("/index.html").redirect("/")
      raw_response = @route_set.call(@env)
      response = Rack::MockResponse.new(*raw_response)
      response.should be_redirect
    end

    it "should redirect '/index.html' to '/'" do
      @route_set.get("/index.html").redirect("/")
      status, headers, body = @route_set.call(@env)
      headers["Location"].should eql("/")
    end
  end

  describe "chaining" do
    it "should be chainable" do
      @route_set.get("/index.html").redirect("/").name(:root)
      url = @route_set.router.generator.generate(:root)
      url.should eql("/index.html")
    end

    it "should not influence actual invoking" do
      @route_set.get("/index.html").redirect("/").name(:root)
      @route_set.call(@env)
    end
  end

  describe "custom status" do
    it "should enable to set custom HTTP status" do
      @route_set.get("/index.html").redirect("/", 303)
      status, headers, body = @route_set.call(@env)
      status.should eql(303)
    end

    it "should raise an exception if given HTTP code isn't a redirection" do
      lambda { @route_set.get("/index.html").redirect("/", 200) }.should raise_error(ArgumentError)
    end
  end
end