require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MembershipsController do
  describe "route generation" do

    it "should map { :controller => 'open_ids', :action => 'index' } to /open_ids" do
      route_for(:controller => "open_ids", :action => "index").should == "/open_ids"
    end
  
    it "should map { :controller => 'open_ids', :action => 'new' } to /open_ids/new" do
      route_for(:controller => "open_ids", :action => "new").should == "/open_ids/new"
    end
  
    it "should map { :controller => 'open_ids', :action => 'show', :id => 1 } to /open_ids/1" do
      route_for(:controller => "open_ids", :action => "show", :id => 1).should == "/open_ids/1"
    end
  
    it "should map { :controller => 'open_ids', :action => 'edit', :id => 1 } to /open_ids/1/edit" do
      route_for(:controller => "open_ids", :action => "edit", :id => 1).should == "/open_ids/1/edit"
    end
  
    it "should map { :controller => 'open_ids', :action => 'update', :id => 1} to /open_ids/1" do
      route_for(:controller => "open_ids", :action => "update", :id => 1).should == "/open_ids/1"
    end
  
    it "should map { :controller => 'open_ids', :action => 'destroy', :id => 1} to /open_ids/1" do
      route_for(:controller => "open_ids", :action => "destroy", :id => 1).should == "/open_ids/1"
    end
  end

  describe "route recognition" do

    it "should generate params { :controller => 'open_ids', action => 'index' } from GET /open_ids" do
      params_from(:get, "/open_ids").should == {:controller => "open_ids", :action => "index"}
    end
  
    it "should generate params { :controller => 'open_ids', action => 'new' } from GET /open_ids/new" do
      params_from(:get, "/open_ids/new").should == {:controller => "open_ids", :action => "new"}
    end
  
    it "should generate params { :controller => 'open_ids', action => 'create' } from POST /open_ids" do
      params_from(:post, "/open_ids").should == {:controller => "open_ids", :action => "create"}
    end
  
    it "should generate params { :controller => 'open_ids', action => 'show', id => '1' } from GET /open_ids/1" do
      params_from(:get, "/open_ids/1").should == {:controller => "open_ids", :action => "show", :id => "1"}
    end
  
    it "should generate params { :controller => 'open_ids', action => 'edit', id => '1' } from GET /open_ids/1;edit" do
      params_from(:get, "/open_ids/1/edit").should == {:controller => "open_ids", :action => "edit", :id => "1"}
    end
  
    it "should generate params { :controller => 'open_ids', action => 'update', id => '1' } from PUT /open_ids/1" do
      params_from(:put, "/open_ids/1").should == {:controller => "open_ids", :action => "update", :id => "1"}
    end
  
    it "should generate params { :controller => 'open_ids', action => 'destroy', id => '1' } from DELETE /open_ids/1" do
      params_from(:delete, "/open_ids/1").should == {:controller => "open_ids", :action => "destroy", :id => "1"}
    end
  end
end
