#
# Copyright (C) 2012 Instructure, Inc.
#
# This file is part of Canvas.
#
# Canvas is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, version 3 of the License.
#
# Canvas is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU Affero General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along
# with this program. If not, see <http://www.gnu.org/licenses/>.
#

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper.rb')

require 'cutycapt'

describe CutyCapt do
  context "url validation" do
    after(:each) do 
      CutyCapt.config = nil
    end
    it "should check with_indifferent_access" do
      Setting.set_config("cutycapt", CutyCapt::CUTYCAPT_DEFAULTS.dup.merge({"path" => 'not used'}))
      CutyCapt.config[:path].should_not be_nil
    end
    it "should check for an http scheme" do
      Setting.set_config("cutycapt", CutyCapt::CUTYCAPT_DEFAULTS.dup.merge({:path => 'not used'}))
      CutyCapt.verify_url("ftp://example.com/").should be_false
      CutyCapt.verify_url("http://example.com/").should be_true
      CutyCapt.verify_url("https://example.com/").should be_true
    end
    
    it "should check for blacklisted domains" do
      Setting.set_config("cutycapt", CutyCapt::CUTYCAPT_DEFAULTS.dup.merge({:path => 'not used', :domain_blacklist => ['example.com']}))
      
      CutyCapt.verify_url("http://example.com/blah").should be_false
      CutyCapt.verify_url("http://foo.example.com/blah").should be_false
      CutyCapt.verify_url("http://bar.foo.example.com/blah").should be_false
      CutyCapt.verify_url("http://google.com/blah").should be_true
    end
    
    it "should check for blacklisted ip blocks" do
      Setting.set_config("cutycapt", CutyCapt::CUTYCAPT_DEFAULTS.dup.merge({:path => 'not used'}))
      
      CutyCapt.verify_url("http://10.0.1.1/blah").should be_false
      CutyCapt.verify_url("http://169.254.169.254/blah").should be_false
      CutyCapt.verify_url("http://4.4.4.4/blah").should be_true
      
      Resolv.stubs(:getaddresses).returns([ "8.8.8.8", "10.0.1.1" ])
      CutyCapt.verify_url("http://workingexample.com/blah").should be_false
    end
  end
end
