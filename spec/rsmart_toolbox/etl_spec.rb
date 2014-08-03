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

  describe '#valid_value' do
    it "tests semantic equality against a set of valid values" do
      expect(ETL.valid_value(1, [1, 2, 3])).to eq(true)
      expect(ETL.valid_value(2, [1, 2, 3])).to eq(true)
      expect(ETL.valid_value(3, [1, 2, 3])).to eq(true)
      expect(ETL.valid_value(1, [2, 3])).to eq(false)
      expect(ETL.valid_value("1", ["1"])).to eq(true)
      expect(ETL.valid_value("1", ["2"])).to eq(false)
      expect(ETL.valid_value("1", [1])).to eq(false)
    end

    it "provides a case_sensitive option" do
      expect(ETL.valid_value("one", ["ONE"], case_sensitive: false)).to eq(true)
      expect(ETL.valid_value("one", ["ONE"], case_sensitive: true)).to eq(false)
      expect(ETL.valid_value("one", ["one"], case_sensitive: true)).to eq(true)
      expect(ETL.valid_value("one", ["ONE"], case_sensitive: "foo")).to eq(false)
      expect(ETL.valid_value("one", ["ONE"])).to eq(false)
    end

    it "allows for a valid_values that is a regular expression" do
      expect(ETL.valid_value("word", /^(\w+)$/)).to eq(true)
      expect(ETL.valid_value("Z", /^(B|A|Z)?$/)).to eq(true)
      expect(ETL.valid_value("", /^(B|A|Z)?$/)).to eq(true)
      expect(ETL.valid_value("upper", /^(UPPER)$/i)).to eq(true)

      expect(ETL.valid_value("false", /^(true)$/)).to eq(false)
      expect(ETL.valid_value("", "^(B|A|Z)+$")).to eq(false)
    end
  end

  describe "#parse_boolean" do
    true_valid_values  = ['active', 'a', 'true', 't', 'yes', 'y', '1']
    false_valid_values = ['inactive', 'i', 'false', 'f', 'no', 'n', '0']

    it "converts all valid, exact case 'true' Strings to true Booleans" do
      true_valid_values.each do |valid_value|
        expect(ETL.parse_boolean(valid_value)).to eq(true)
      end
    end

    it "converts all valid, lowercase 'true' Strings to true Booleans" do
      true_valid_values.each do |valid_value|
        expect(ETL.parse_boolean(valid_value.downcase)).to eq(true)
      end
    end

    it "converts all valid, mixed case 'true' Strings to true Booleans" do
      true_valid_values.each do |valid_value|
        expect(ETL.parse_boolean(valid_value.capitalize)).to eq(true)
      end
    end

    it "converts all valid, exact case 'false' Strings to false Booleans" do
      false_valid_values.each do |valid_value|
        expect(ETL.parse_boolean(valid_value)).to eq(false)
      end
    end

    it "converts all valid, lowercase 'false' Strings to false Booleans" do
      false_valid_values.each do |valid_value|
        expect(ETL.parse_boolean(valid_value.downcase)).to eq(false)
      end
    end

    it "converts all valid, mixed case 'false' Strings to false Booleans" do
      false_valid_values.each do |valid_value|
        expect(ETL.parse_boolean(valid_value.capitalize)).to eq(false)
      end
    end

    it "handles Booleans in addition to Strings" do
      expect(ETL.parse_boolean(true)).to eq(true)
      expect(ETL.parse_boolean(false)).to eq(false)
    end

    it "converts '' Strings to nil" do
      expect(ETL.parse_boolean('')).to eq(nil)
      expect { ETL.parse_boolean('') }.not_to raise_error
    end

    it "converts nil to nil" do
      expect(ETL.parse_boolean(nil)).to eq(nil)
      expect { ETL.parse_boolean(nil) }.not_to raise_error
    end

    it "throws an Exception when an invalid string is passed" do
      expect { ETL.parse_boolean("foober") }.to raise_error(TextParseError)
    end

    it "supports use of the :required option" do
      expect { ETL.parse_boolean(nil, required: true) }.to raise_error(TextParseError)
      expect { ETL.parse_boolean(nil, required: false) }.not_to raise_error
    end

    it "supports use of the :default option" do
      expect(ETL.parse_boolean("",  default: true)).to  eq true
      expect(ETL.parse_boolean(nil, default: true)).to  eq true
      expect(ETL.parse_boolean("",  default: "yes")).to eq true
      expect(ETL.parse_boolean(nil, default: "yes")).to eq true

      expect(ETL.parse_boolean("",  default: false)).to eq false
      expect(ETL.parse_boolean(nil, default: false)).to eq false
      expect(ETL.parse_boolean("",  default: "no")).to  eq false
      expect(ETL.parse_boolean(nil, default: "no")).to  eq false
    end
  end

  describe "#escape_single_quotes" do
    it "Escapes any single quotes in a String with a '\' character" do
      expect(ETL.escape_single_quotes("That's it")).to eq("That\\\'s it")
      expect(ETL.escape_single_quotes("Thats it")).to eq("Thats it")
      expect(ETL.escape_single_quotes("")).to eq("")
      expect(ETL.escape_single_quotes(nil)).to eq(nil)
    end
  end

  describe "#parse_string" do
    it "Escapes any single quotes in a String with a '\' character" do
      expect(ETL.parse_string("That's it")).to eq("That\\\'s it")
      expect(ETL.parse_string("Thats it")).to  eq("Thats it")
    end

    it "Returns empty string if nil or an empty string is passed" do
      expect(ETL.parse_string("")).to  eq("")
      expect(ETL.parse_string(nil)).to eq("")
    end

    it "Supports a :required option" do
      expect { ETL.parse_string("",  required: true)  }.to raise_error(TextParseError)
      expect { ETL.parse_string(nil, required: true)  }.to raise_error(TextParseError)
      expect { ETL.parse_string("",  required: false) }.not_to raise_error
      expect { ETL.parse_string(nil, required: false) }.not_to raise_error
    end

    it "Supports a :default option if no String is found" do
      expect(ETL.parse_string("",  default: "foo")).to eq("foo")
      expect(ETL.parse_string(nil, default: "foo")).to eq("foo")
    end

    it "Ignores the :default option if a String is found" do
      expect(ETL.parse_string("bar", default: "foo")).to eq("bar")
    end

    it "performs a :length validation" do
      expect { ETL.parse_string("123", length: 1) }.to raise_error(TextParseError)
    end

    it "allows you to disable :strict :length validation" do
      expect { ETL.parse_string("123", length: 1, strict: false) }.not_to raise_error
    end

    it "Supports a :valid_values validation semantics" do
      expect { ETL.parse_string("123", valid_values: /456/) }.to   raise_error(TextParseError)
      expect { ETL.parse_string("123", valid_values: ['456']) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_string!" do
    it "Modifies the insert_str and values_str based on a CSV::Row match" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['rolodex_id'.to_sym], ['123ABC'], true)
      ETL.parse_string!(row, insert_str, values_str, name: "ROLODEX_ID")
      expect(insert_str).to eq "ROLODEX_ID,"
      expect(values_str).to eq "'123ABC',"
    end

    it "is not required by default and mutates with an empty string" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['rolodex_id'.to_sym], [''], true)
      ETL.parse_string!(row, insert_str, values_str, name: "ROLODEX_ID")
      expect(insert_str).to eq "ROLODEX_ID,"
      expect(values_str).to eq "'',"
    end
  end

  describe "#parse_integer" do
    it "Converts Strings into Integers" do
      expect(ETL.parse_integer("1")).to eq(1)
      expect(ETL.parse_integer("0")).to eq(0)
    end

    it "Supports passing Integers for convenience" do
      expect(ETL.parse_integer(1)).to eq(1)
      expect(ETL.parse_integer(0)).to eq(0)
    end

    it "Returns nil if no value is found instead of 0" do
      expect(ETL.parse_integer("")).to eq(nil)
      expect(ETL.parse_integer(nil)).to eq(nil)
    end

    it "Raises an TextParseError if String is nil or empty and is required" do
      expect { ETL.parse_integer(nil, required: true) }.to raise_error(TextParseError)
      expect { ETL.parse_integer("", required: true ) }.to raise_error(TextParseError)
    end

    it "Supports :default option" do
      expect(ETL.parse_integer("", default: '1', required: false)).to eq(1)
      expect(ETL.parse_integer("", default:  2,  required: false)).to eq(2)
    end

    it "Enforces strict length validation to avoid loss of precision" do
      expect { ETL.parse_integer("22", length: 1, strict: true) }.to raise_error(TextParseError)
    end

    it "Supports a :valid_values validation semantics" do
      expect { ETL.parse_integer("123", valid_values: /456/) }.to   raise_error(TextParseError)
      expect { ETL.parse_integer("123", valid_values: ['456']) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_integer!" do
    it "Modifies the insert_str and values_str based on a CSV::Row match" do
      insert_str = ""; values_str = ""; name = "VALID_CLASS_REPORT_FREQ_ID"
      row = CSV::Row.new([name.downcase.to_sym], ['123'], true)
      ETL.parse_integer!(row, insert_str, values_str, name: name)
      expect(insert_str).to eq "#{name},"
      expect(values_str).to eq "123,"
    end

    # TODO how to handle mutation of column name and value when nil is returned from parse_integer?
  end

  describe "#parse_float" do
    it "Converts Strings into Floats" do
      expect(ETL.parse_float("1.1")).to eq(1.1)
      expect(ETL.parse_float("0.0")).to eq(0.0)
    end

    it "Supports passing floats for convenience" do
      expect(ETL.parse_float(1.1)).to eq(1.1)
      expect(ETL.parse_float(0.0)).to eq(0.0)
    end

    it "Returns nil if no value is found instead of 0" do
      expect(ETL.parse_float("")).to eq(nil)
      expect(ETL.parse_float(nil)).to eq(nil)
    end

    it "Raises an TextParseError if String is nil or empty and is required" do
      expect { ETL.parse_float(nil, required: true) }.to raise_error(TextParseError)
      expect { ETL.parse_float("", required: true ) }.to raise_error(TextParseError)
    end

    it "Supports :default option" do
      expect(ETL.parse_float("", default: '3.3', required: false)).to eq(3.3)
      expect(ETL.parse_float("", default:  2.2,  required: false)).to eq(2.2)
    end

    it "Enforces strict length validation to avoid loss of precision" do
      expect { ETL.parse_float("2.2", length: 1, strict: true) }.to raise_error(TextParseError)
    end

    it "Supports a :valid_values validation semantics" do
      expect { ETL.parse_float("123.1", valid_values: /456/) }.to   raise_error(TextParseError)
      expect { ETL.parse_float("123.1", valid_values: ['456']) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_actv_ind!" do
    it "Modifies the insert_str and values_str based on a CSV::Row match" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['actv_ind'.to_sym], ['Y'], true)
      ETL.parse_actv_ind!(row, insert_str, values_str)
      expect(insert_str).to eq("ACTV_IND,")
      expect(values_str).to eq("'Y',")
    end

    it "allows for lowercase input Strings" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['actv_ind'.to_sym], ['n'], true)
      ETL.parse_actv_ind!(row, insert_str, values_str)
      expect(insert_str).to eq("ACTV_IND,")
      expect(values_str).to eq("'N',")
    end

    it "Returns a default value of 'Y' and does not raise an TextParseError if nil or empty" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['actv_ind'.to_sym], [nil], true)
      expect { ETL.parse_actv_ind!(row, insert_str, values_str) }.not_to raise_error
      expect(insert_str).to eq("ACTV_IND,")
      expect(values_str).to eq("'Y',")
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['actv_ind'.to_sym], [''], true)
      expect { ETL.parse_actv_ind!(row, insert_str, values_str) }.not_to raise_error
      expect(insert_str).to eq("ACTV_IND,")
      expect(values_str).to eq("'Y',")
    end

    it "Raises an TextParseError if not a valid 'Y/N' value" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['actv_ind'.to_sym], ["Q"], true)
      expect { ETL.parse_actv_ind!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end

    it "Raises an TextParseError if length exceeds 1 characters" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['actv_ind'.to_sym], ["x" * 2], true)
      expect { ETL.parse_actv_ind!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end
  end

  describe "#to_symbol" do
    it "is downcased" do
      sample = ETL.to_symbol "ROLODEX_ID"
      expect(sample).to eq("rolodex_id".to_sym)
    end

    it "spaces are replaced with underscores" do
      sample = ETL.to_symbol "ROLODEX_ID "
      expect(sample).to eq("rolodex_id_".to_sym)
    end

    it "non-word characters are dropped" do
      sample = ETL.to_symbol "ROLODEX_ID&"
      expect(sample).to eq("rolodex_id".to_sym)
    end
  end

  describe "#parse_csv_command_line_options" do
    executable = "foo.rb"
    args = ["/some/file.csv"]

    it "sets opt[:sql_filename] to a reasonable default value when none is suppied" do
      opt = ETL.parse_csv_command_line_options(executable, args)
      expect(opt[:sql_filename]).to eq("/some/file.sql")
    end

    it "sets opt[:csv_filename] to args[0] when a value is supplied" do
      opt = ETL.parse_csv_command_line_options(executable, args)
      expect(opt[:csv_filename]).to eq("/some/file.csv")
    end

    it "allows the caller to specify opt[:sql_filename] on the command line" do
      subject = { sql_filename: "/some/other/file.sql" }
      opt = ETL.parse_csv_command_line_options(executable, args, subject)
      expect(opt[:sql_filename]).to eq("/some/other/file.sql")
    end

    it "provides good default CSV parsing options" do
      opt = ETL.parse_csv_command_line_options(executable, args)
      expect(opt[:csv_options][:headers]).to eq(:first_row)
      expect(opt[:csv_options][:header_converters]).to eq(:symbol)
      expect(opt[:csv_options][:skip_blanks]).to eq(true)
      expect(opt[:csv_options][:col_sep]).to eq(',')
      expect(opt[:csv_options][:quote_char]).to eq('"')
    end

    it "allows you to override the CSV parsing options" do
      opt = ETL.parse_csv_command_line_options(executable, args, csv_options: {col_sep: '|', quote_char: '`'})
      expect(opt[:csv_options][:col_sep]).to eq('|')
      expect(opt[:csv_options][:quote_char]).to eq('`')
    end

    it "exits with code 1 if no csv_filename is provided on the command line" do
      begin
        ETL.parse_csv_command_line_options(executable, [])
      rescue SystemExit => e
        expect(e.status).to eq 1 # exited with failure status
      else
        raise "Unexpected Exception found: #{e.class}"
      end
    end
  end

end
