# rSmart client library and command-line tool to help interact with rSmart's cloud APIs.
# Copyright (C) 2014 The rSmart Group, Inc.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'spec_helper'
require 'rsmart_toolbox/etl'

ETL = RsmartToolbox::ETL

RSpec.describe "RsmartToolbox::ETL" do
  describe "#error" do
    it "it returns a TextParseError when passed a String" do
      expect(ETL::error("foo")).to be_kind_of TextParseError
    end

    it "reformats the message with additional context information" do
      e = ETL::error("foo")
      expect(e.message).to include "foo"
      expect(e.message).to match /^ERROR:\s+Line\s+(\d+):\s+.+$/
    end

    it "supports passing Exceptions and maintains type" do
      e1 = NotImplementedError.new "foo"
      e2 = ETL::error(e1)
      expect(ETL::error(e2)).to be_kind_of NotImplementedError
    end

    it "supports passing Exceptions and maintains message" do
      e1 = NotImplementedError.new "foo"
      e2 = ETL::error(e1)
      expect(e2.message).to include e1.message
      expect(e2.message).to match /^ERROR:\s+Line\s+(\d+):\s+.+$/
    end

    it "raises an ArgumentError if passed an unsupported type" do
      expect { ETL::error("foo".to_i) }.to raise_error(ArgumentError)
    end
  end

  describe "#warning" do
    it "it returns a TextParseError when passed a String" do
      expect(ETL::warning("foo")).to be_kind_of TextParseError
    end

    it "reformats the message with additional context information" do
      e = ETL::warning("foo")
      expect(e.message).to include "foo"
      expect(e.message).to match /^WARN:\s+Line\s+(\d+):\s+.+$/
    end

    it "supports passing Exceptions and maintains type" do
      e1 = NotImplementedError.new "foo"
      e2 = ETL::warning(e1)
      expect(ETL::warning(e2)).to be_kind_of NotImplementedError
    end

    it "supports passing Exceptions and maintains message" do
      e1 = NotImplementedError.new "foo"
      e2 = ETL::warning(e1)
      expect(e2.message).to include e1.message
      expect(e2.message).to match /^WARN:\s+Line\s+(\d+):\s+.+$/
    end

    it "raises an ArgumentError if passed an unsupported type" do
      expect { ETL::warning("foo".to_i) }.to raise_error(ArgumentError)
    end
  end

end
