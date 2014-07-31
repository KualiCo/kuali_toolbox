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
require 'rsmart_toolbox'

CX = RsmartToolbox::CX
TextParseError = RsmartToolbox::TextParseError

RSpec.describe CX do
  describe '#valid_value' do
    it "tests semantic equality against a set of valid values" do
      expect(CX.valid_value(1, [1, 2, 3])).to eq(true)
      expect(CX.valid_value(2, [1, 2, 3])).to eq(true)
      expect(CX.valid_value(3, [1, 2, 3])).to eq(true)
      expect(CX.valid_value(1, [2, 3])).to eq(false)
      expect(CX.valid_value("1", ["1"])).to eq(true)
      expect(CX.valid_value("1", ["2"])).to eq(false)
      expect(CX.valid_value("1", [1])).to eq(false)
    end

    it "provides a case_sensitive option" do
      expect(CX.valid_value("one", ["ONE"], case_sensitive: false)).to eq(true)
      expect(CX.valid_value("one", ["ONE"], case_sensitive: true)).to eq(false)
      expect(CX.valid_value("one", ["one"], case_sensitive: true)).to eq(true)
      expect(CX.valid_value("one", ["ONE"], case_sensitive: "foo")).to eq(false)
      expect(CX.valid_value("one", ["ONE"])).to eq(false)
    end

    it "allows for a valid_values that is a regular expression" do
      expect(CX.valid_value("word", /^(\w+)$/)).to eq(true)
      expect(CX.valid_value("Z", /^(B|A|Z)?$/)).to eq(true)
      expect(CX.valid_value("", /^(B|A|Z)?$/)).to eq(true)
      expect(CX.valid_value("upper", /^(UPPER)$/i)).to eq(true)

      expect(CX.valid_value("false", /^(true)$/)).to eq(false)
      expect(CX.valid_value("", "^(B|A|Z)+$")).to eq(false)
    end
  end

  describe "#parse_boolean" do
    true_valid_values  = ['active', 'a', 'true', 't', 'yes', 'y', '1']
    false_valid_values = ['inactive', 'i', 'false', 'f', 'no', 'n', '0']

    it "converts all valid, exact case 'true' Strings to true Booleans" do
      true_valid_values.each do |valid_value|
        expect(CX.parse_boolean(valid_value)).to eq(true)
      end
    end

    it "converts all valid, lowercase 'true' Strings to true Booleans" do
      true_valid_values.each do |valid_value|
        expect(CX.parse_boolean(valid_value.downcase)).to eq(true)
      end
    end

    it "converts all valid, mixed case 'true' Strings to true Booleans" do
      true_valid_values.each do |valid_value|
        expect(CX.parse_boolean(valid_value.capitalize)).to eq(true)
      end
    end

    it "converts all valid, exact case 'false' Strings to false Booleans" do
      false_valid_values.each do |valid_value|
        expect(CX.parse_boolean(valid_value)).to eq(false)
      end
    end

    it "converts all valid, lowercase 'false' Strings to false Booleans" do
      false_valid_values.each do |valid_value|
        expect(CX.parse_boolean(valid_value.downcase)).to eq(false)
      end
    end

    it "converts all valid, mixed case 'false' Strings to false Booleans" do
      false_valid_values.each do |valid_value|
        expect(CX.parse_boolean(valid_value.capitalize)).to eq(false)
      end
    end

    it "handles Booleans in addition to Strings" do
      expect(CX.parse_boolean(true)).to eq(true)
      expect(CX.parse_boolean(false)).to eq(false)
    end

    it "converts '' Strings to nil" do
      expect(CX.parse_boolean('')).to eq(nil)
      expect { CX.parse_boolean('') }.not_to raise_error
    end

    it "converts nil to nil" do
      expect(CX.parse_boolean(nil)).to eq(nil)
      expect { CX.parse_boolean(nil) }.not_to raise_error
    end

    it "throws an Exception when an invalid string is passed" do
      expect { CX.parse_boolean("foober") }.to raise_error(TextParseError)
    end

    it "supports use of the :required option" do
      expect { CX.parse_boolean(nil, required: true) }.to raise_error(TextParseError)
      expect { CX.parse_boolean(nil, required: false) }.not_to raise_error
    end

    it "supports use of the :default option" do
      expect(CX.parse_boolean("",  default: true)).to  eq true
      expect(CX.parse_boolean(nil, default: true)).to  eq true
      expect(CX.parse_boolean("",  default: "yes")).to eq true
      expect(CX.parse_boolean(nil, default: "yes")).to eq true

      expect(CX.parse_boolean("",  default: false)).to eq false
      expect(CX.parse_boolean(nil, default: false)).to eq false
      expect(CX.parse_boolean("",  default: "no")).to  eq false
      expect(CX.parse_boolean(nil, default: "no")).to  eq false
    end
  end

  describe "#escape_single_quotes" do
    it "Escapes any single quotes in a String with a '\' character" do
      expect(CX.escape_single_quotes("That's it")).to eq("That\\\'s it")
      expect(CX.escape_single_quotes("Thats it")).to eq("Thats it")
      expect(CX.escape_single_quotes("")).to eq("")
      expect(CX.escape_single_quotes(nil)).to eq(nil)
    end
  end

  describe "#parse_string" do
    it "Escapes any single quotes in a String with a '\' character" do
      expect(CX.parse_string("That's it")).to eq("That\\\'s it")
      expect(CX.parse_string("Thats it")).to  eq("Thats it")
    end

    it "Returns empty string if nil or an empty string is passed" do
      expect(CX.parse_string("")).to  eq("")
      expect(CX.parse_string(nil)).to eq("")
    end

    it "Supports a :required option" do
      expect { CX.parse_string("",  required: true)  }.to raise_error(TextParseError)
      expect { CX.parse_string(nil, required: true)  }.to raise_error(TextParseError)
      expect { CX.parse_string("",  required: false) }.not_to raise_error
      expect { CX.parse_string(nil, required: false) }.not_to raise_error
    end

    it "Supports a :default option if no String is found" do
      expect(CX.parse_string("",  default: "foo")).to eq("foo")
      expect(CX.parse_string(nil, default: "foo")).to eq("foo")
    end

    it "Ignores the :default option if a String is found" do
      expect(CX.parse_string("bar", default: "foo")).to eq("bar")
    end

    it "performs a :length validation" do
      expect { CX.parse_string("123", length: 1) }.to raise_error(TextParseError)
    end

    it "allows you to disable :strict :length validation" do
      expect { CX.parse_string("123", length: 1, strict: false) }.not_to raise_error
    end

    it "Supports a :valid_values validation semantics" do
      expect { CX.parse_string("123", valid_values: /456/) }.to   raise_error(TextParseError)
      expect { CX.parse_string("123", valid_values: ['456']) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_string!" do
    it "Modifies the insert_str and values_str based on a CSV::Row match" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['rolodex_id'.to_sym], ['123ABC'], true)
      CX.parse_string!(row, insert_str, values_str, name: "ROLODEX_ID")
      expect(insert_str).to eq "ROLODEX_ID,"
      expect(values_str).to eq "'123ABC',"
    end

    it "is not required by default and mutates with an empty string" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['rolodex_id'.to_sym], [''], true)
      CX.parse_string!(row, insert_str, values_str, name: "ROLODEX_ID")
      expect(insert_str).to eq "ROLODEX_ID,"
      expect(values_str).to eq "'',"
    end
  end

  describe "#parse_integer" do
    it "Converts Strings into Integers" do
      expect(CX.parse_integer("1")).to eq(1)
      expect(CX.parse_integer("0")).to eq(0)
    end

    it "Supports passing Integers for convenience" do
      expect(CX.parse_integer(1)).to eq(1)
      expect(CX.parse_integer(0)).to eq(0)
    end

    it "Returns nil if no value is found instead of 0" do
      expect(CX.parse_integer("")).to eq(nil)
      expect(CX.parse_integer(nil)).to eq(nil)
    end

    it "Raises an TextParseError if String is nil or empty and is required" do
      expect { CX.parse_integer(nil, required: true) }.to raise_error(TextParseError)
      expect { CX.parse_integer("", required: true ) }.to raise_error(TextParseError)
    end

    it "Supports :default option" do
      expect(CX.parse_integer("", default: '1', required: false)).to eq(1)
      expect(CX.parse_integer("", default:  2,  required: false)).to eq(2)
    end

    it "Enforces strict length validation to avoid loss of precision" do
      expect { CX.parse_integer("22", length: 1, strict: true) }.to raise_error(TextParseError)
    end

    it "Supports a :valid_values validation semantics" do
      expect { CX.parse_integer("123", valid_values: /456/) }.to   raise_error(TextParseError)
      expect { CX.parse_integer("123", valid_values: ['456']) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_integer!" do
    it "Modifies the insert_str and values_str based on a CSV::Row match" do
      insert_str = ""; values_str = ""; name = "VALID_CLASS_REPORT_FREQ_ID"
      row = CSV::Row.new([name.downcase.to_sym], ['123'], true)
      CX.parse_integer!(row, insert_str, values_str, name: name)
      expect(insert_str).to eq "#{name},"
      expect(values_str).to eq "123,"
    end

    # TODO how to handle mutation of column name and value when nil is returned from parse_integer?
  end

  describe "#parse_float" do
    it "Converts Strings into Floats" do
      expect(CX.parse_float("1.1")).to eq(1.1)
      expect(CX.parse_float("0.0")).to eq(0.0)
    end

    it "Supports passing floats for convenience" do
      expect(CX.parse_float(1.1)).to eq(1.1)
      expect(CX.parse_float(0.0)).to eq(0.0)
    end

    it "Returns nil if no value is found instead of 0" do
      expect(CX.parse_float("")).to eq(nil)
      expect(CX.parse_float(nil)).to eq(nil)
    end

    it "Raises an TextParseError if String is nil or empty and is required" do
      expect { CX.parse_float(nil, required: true) }.to raise_error(TextParseError)
      expect { CX.parse_float("", required: true ) }.to raise_error(TextParseError)
    end

    it "Supports :default option" do
      expect(CX.parse_float("", default: '3.3', required: false)).to eq(3.3)
      expect(CX.parse_float("", default:  2.2,  required: false)).to eq(2.2)
    end

    it "Enforces strict length validation to avoid loss of precision" do
      expect { CX.parse_float("2.2", length: 1, strict: true) }.to raise_error(TextParseError)
    end

    it "Supports a :valid_values validation semantics" do
      expect { CX.parse_float("123.1", valid_values: /456/) }.to   raise_error(TextParseError)
      expect { CX.parse_float("123.1", valid_values: ['456']) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_rolodex_id!" do
    it "Modifies the insert_str and values_str based on a CSV::Row match" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['rolodex_id'.to_sym], ['123456'], true)
      CX.parse_rolodex_id!(row, insert_str, values_str)
      expect(insert_str).to eq("ROLODEX_ID,")
      expect(values_str).to eq("'123456',")
    end

    it "Raises an TextParseError if nil or empty" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['rolodex_id'.to_sym], [nil], true)
      expect { CX.parse_rolodex_id!(row, insert_str, values_str) }.to raise_error(TextParseError)
      row = CSV::Row.new(['rolodex_id'.to_sym], [''], true)
      expect { CX.parse_rolodex_id!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end

    it "Raises an TextParseError if length exceeds 6 characters" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['rolodex_id'.to_sym], ['1234567'], true)
      expect { CX.parse_rolodex_id!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_country_code!" do
    it "Modifies the insert_str and values_str based on a CSV::Row match" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['country_code'.to_sym], ['USA'], true)
      CX.parse_country_code!(row, insert_str, values_str)
      expect(insert_str).to eq("COUNTRY_CODE,")
      expect(values_str).to eq("'USA',")
    end

    it "Does not raise an TextParseError if nil or empty" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['country_code'.to_sym], [nil], true)
      expect { CX.parse_country_code!(row, insert_str, values_str) }.not_to raise_error
      row = CSV::Row.new(['country_code'.to_sym], [''], true)
      expect { CX.parse_country_code!(row, insert_str, values_str) }.not_to raise_error
    end

    it "Raises an TextParseError if length exceeds 4 characters" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['country_code'.to_sym], ['FOUR'], true)
      expect { CX.parse_country_code!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_state!" do
    it "Modifies the insert_str and values_str based on a CSV::Row match" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['state'.to_sym], ['Arizona'], true)
      CX.parse_state!(row, insert_str, values_str)
      expect(insert_str).to eq("STATE,")
      expect(values_str).to eq("'Arizona',")
    end

    it "Does not raise an TextParseError if nil or empty" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['state'.to_sym], [nil], true)
      expect { CX.parse_state!(row, insert_str, values_str) }.not_to raise_error
      row = CSV::Row.new(['state'.to_sym], [''], true)
      expect { CX.parse_state!(row, insert_str, values_str) }.not_to raise_error
    end

    it "Raises an TextParseError if length exceeds 30 characters" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['state'.to_sym], ["x" * 31], true)
      expect { CX.parse_state!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_sponsor_code!" do
    it "Modifies the insert_str and values_str based on a CSV::Row match" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['sponsor_code'.to_sym], ['000001'], true)
      CX.parse_sponsor_code!(row, insert_str, values_str)
      expect(insert_str).to eq("SPONSOR_CODE,")
      expect(values_str).to eq("'000001',")
    end

    it "Raises an TextParseError if nil or empty" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['sponsor_code'.to_sym], [nil], true)
      expect { CX.parse_sponsor_code!(row, insert_str, values_str) }.to raise_error(TextParseError)
      row = CSV::Row.new(['sponsor_code'.to_sym], [""], true)
      expect { CX.parse_sponsor_code!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end

    it "Raises an TextParseError if length exceeds 6 characters" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['sponsor_code'.to_sym], ["x" * 7], true)
      expect { CX.parse_sponsor_code!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_postal_code!" do
    it "Modifies the insert_str and values_str based on a CSV::Row match" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['postal_code'.to_sym], ['12345-7890'], true)
      CX.parse_postal_code!(row, insert_str, values_str)
      expect(insert_str).to eq("POSTAL_CODE,")
      expect(values_str).to eq("'12345-7890',")
    end

    it "Does not raise an TextParseError if nil or empty" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['postal_code'.to_sym], [nil], true)
      expect { CX.parse_postal_code!(row, insert_str, values_str) }.not_to raise_error
      row = CSV::Row.new(['postal_code'.to_sym], [''], true)
      expect { CX.parse_postal_code!(row, insert_str, values_str) }.not_to raise_error
    end

    it "Raises an TextParseError if length exceeds 15 characters" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['postal_code'.to_sym], ["x" * 16], true)
      expect { CX.parse_postal_code!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_owned_by_unit!" do
    it "Modifies the insert_str and values_str based on a CSV::Row match" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['owned_by_unit'.to_sym], ['000001'], true)
      CX.parse_owned_by_unit!(row, insert_str, values_str)
      expect(insert_str).to eq("OWNED_BY_UNIT,")
      expect(values_str).to eq("'000001',")
    end

    it "Raises an TextParseError if nil or empty" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['owned_by_unit'.to_sym], [nil], true)
      expect { CX.parse_owned_by_unit!(row, insert_str, values_str) }.to raise_error(TextParseError)
      row = CSV::Row.new(['owned_by_unit'.to_sym], [''], true)
      expect { CX.parse_owned_by_unit!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end

    it "Raises an TextParseError if length exceeds 8 characters" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['owned_by_unit'.to_sym], ["x" * 9], true)
      expect { CX.parse_owned_by_unit!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_actv_ind!" do
    it "Modifies the insert_str and values_str based on a CSV::Row match" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['actv_ind'.to_sym], ['Y'], true)
      CX.parse_actv_ind!(row, insert_str, values_str)
      expect(insert_str).to eq("ACTV_IND,")
      expect(values_str).to eq("'Y',")
    end

    it "allows for lowercase input Strings" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['actv_ind'.to_sym], ['n'], true)
      CX.parse_actv_ind!(row, insert_str, values_str)
      expect(insert_str).to eq("ACTV_IND,")
      expect(values_str).to eq("'N',")
    end

    it "Returns a default value of 'Y' and does not raise an TextParseError if nil or empty" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['actv_ind'.to_sym], [nil], true)
      expect { CX.parse_actv_ind!(row, insert_str, values_str) }.not_to raise_error
      expect(insert_str).to eq("ACTV_IND,")
      expect(values_str).to eq("'Y',")
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['actv_ind'.to_sym], [''], true)
      expect { CX.parse_actv_ind!(row, insert_str, values_str) }.not_to raise_error
      expect(insert_str).to eq("ACTV_IND,")
      expect(values_str).to eq("'Y',")
    end

    it "Raises an TextParseError if not a valid 'Y/N' value" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['actv_ind'.to_sym], ["Q"], true)
      expect { CX.parse_actv_ind!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end

    it "Raises an TextParseError if length exceeds 1 characters" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['actv_ind'.to_sym], ["x" * 2], true)
      expect { CX.parse_actv_ind!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_email_address!" do
    it "Modifies the insert_str and values_str based on a CSV::Row match" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['email_address'.to_sym], ['lance@rsmart.com'], true)
      CX.parse_email_address!(row, insert_str, values_str)
      expect(insert_str).to eq("EMAIL_ADDRESS,")
      expect(values_str).to eq("'lance@rsmart.com',")
    end

    it "Does not raise an TextParseError if nil or empty" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['email_address'.to_sym], [nil], true)
      expect { CX.parse_email_address!(row, insert_str, values_str) }.not_to raise_error
      row = CSV::Row.new(['email_address'.to_sym], [''], true)
      expect { CX.parse_email_address!(row, insert_str, values_str) }.not_to raise_error
    end

    it "Raises an TextParseError if length exceeds 60 characters" do
      insert_str = ""; values_str = "";
      valid_sixty_one_char_email_address = "abcedefghijksdhfksjfdsdfsdfsdfsdhsjkhdf@abcdesfsdfsdfsdff.com"
      row = CSV::Row.new(['email_address'.to_sym], [valid_sixty_one_char_email_address], true)
      expect { CX.parse_email_address!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end

    it "Raises an TextParseError if it does not match the official RFC email address specifications" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['email_address'.to_sym], ["foo"], true)
      expect { CX.parse_email_address!(row, insert_str, values_str) }.to raise_error(TextParseError)
      row = CSV::Row.new(['email_address'.to_sym], ["foo@bar"], true)
      expect { CX.parse_email_address!(row, insert_str, values_str) }.to raise_error(TextParseError)
      row = CSV::Row.new(['email_address'.to_sym], ["foo@bar."], true)
      expect { CX.parse_email_address!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_principal_id" do
    it "parses a principal_id from a String" do
      expect(CX.parse_principal_id("ABCD1234")).to eq("ABCD1234")
    end

    it "raises an TextParseError if the principal_id is nil or empty" do
      expect { CX.parse_principal_id(nil) }.to raise_error(TextParseError)
      expect { CX.parse_principal_id("") }.to  raise_error(TextParseError)
    end

    it "raises an TextParseError if length exceeds 40 characters" do
      expect { CX.parse_principal_id("x" * 41) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_principal_name" do
    it "parses a principal_nm from a String" do
      expect(CX.parse_principal_name("lspeelmon")).to eq("lspeelmon")
    end

    it "raises an TextParseError if the principal_nm is nil or empty" do
      expect { CX.parse_principal_name(nil) }.to raise_error(TextParseError)
      expect { CX.parse_principal_name("") }.to  raise_error(TextParseError)
    end

    it "raises an TextParseError if the principal_nm contains illegal characters" do
      expect { CX.parse_principal_name("~!#$%^&*()+=") }.to raise_error(TextParseError)
      expect { CX.parse_principal_name("LANCE@UPPERCASE.COM") }.to raise_error(TextParseError)
    end

    it "raises an TextParseError if length exceeds 100 characters" do
      expect { CX.parse_principal_name("x" * 101) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_emp_stat_cd" do
    # <xs:maxLength value="1"/>
    # <xs:pattern value="A|D|L|N|P|R|S|T"/>
    valid_values = ['A', 'D', 'L', 'N', 'P', 'R', 'S', 'T']

    it "parses a emp_stat_cd from a String" do
      valid_values.each do |valid_value|
        expect(CX.parse_emp_stat_cd(valid_value)).to eq(valid_value)
      end
    end

    it "allows for lowercase input Strings" do
      valid_values.each do |valid_value|
        expect(CX.parse_emp_stat_cd(valid_value.downcase)).to eq(valid_value)
      end
    end

    it "allows for mixed case input Strings" do
      valid_values.each do |valid_value|
        expect(CX.parse_emp_stat_cd(valid_value.capitalize)).to eq(valid_value)
      end
    end

    it "raises an TextParseError if the emp_typ_cd is not a valid value" do
      expect { CX.parse_emp_stat_cd("Z") }.to raise_error(TextParseError)
    end

    it "raises an TextParseError if the emp_stat_cd is nil or empty" do
      expect { CX.parse_emp_stat_cd(nil) }.to raise_error(TextParseError)
      expect { CX.parse_emp_stat_cd("") }.to  raise_error(TextParseError)
    end

    it "raises an TextParseError if length exceeds 40 characters" do
      expect { CX.parse_emp_stat_cd("A" * 41) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_emp_typ_cd" do
    # <xs:pattern value="N|O|P"/>
    valid_values = ['N', 'O', 'P']

    it "parses a emp_typ_cd from a String" do
      valid_values.each do |valid_value|
        expect(CX.parse_emp_typ_cd(valid_value)).to eq(valid_value)
      end
    end

    it "allows for lowercase input Strings" do
      valid_values.each do |valid_value|
        expect(CX.parse_emp_typ_cd(valid_value.downcase)).to eq(valid_value)
      end
    end

    it "allows for mixed case input Strings" do
      valid_values.each do |valid_value|
        expect(CX.parse_emp_typ_cd(valid_value.capitalize)).to eq(valid_value)
      end
    end

    it "raises an TextParseError if the emp_typ_cd is not a valid value" do
      expect { CX.parse_emp_typ_cd("Z") }.to raise_error(TextParseError)
    end

    it "raises an TextParseError if the emp_typ_cd is nil or empty" do
      expect { CX.parse_emp_typ_cd(nil) }.to raise_error(TextParseError)
      expect { CX.parse_emp_typ_cd("") }.to  raise_error(TextParseError)
    end

    #  <xs:maxLength value="1"/>
    it "raises an TextParseError if length exceeds 1 character" do
      expect { CX.parse_emp_typ_cd("NN") }.to raise_error(TextParseError)
    end
  end

  describe "#parse_address_type_code" do
    # <xs:pattern value="HM|OTH|WRK"/>
    valid_values = ['HM', 'OTH', 'WRK']

    it "parses all valid address_type_code from a String" do
      valid_values.each do |valid_value|
        expect(CX.parse_address_type_code(valid_value)).to eq(valid_value)
      end
    end

    it "allows for lowercase input Strings" do
      valid_values.each do |valid_value|
        expect(CX.parse_address_type_code(valid_value.downcase)).to eq(valid_value)
      end
    end

    it "allows for mixed case input Strings" do
      valid_values.each do |valid_value|
        expect(CX.parse_address_type_code(valid_value.capitalize)).to eq(valid_value)
      end
    end

    it "raises an TextParseError if the address_type_code is not a valid value" do
      expect { CX.parse_address_type_code("Z") }.to raise_error(TextParseError)
    end

    it "raises an TextParseError if the address_type_code is nil or empty" do
      expect { CX.parse_address_type_code(nil) }.to raise_error(TextParseError)
      expect { CX.parse_address_type_code("") }.to  raise_error(TextParseError)
    end

    # <xs:maxLength value="3"/>
    it "raises an TextParseError if length exceeds 3 characters" do
      expect { CX.parse_address_type_code("HOME") }.to raise_error(TextParseError)
    end
  end

  describe "#parse_name_code" do
    # <xs:pattern value="OTH|PRFR|PRM"/>
    valid_values = ['OTH', 'PRFR', 'PRM']

    it "parses a name_code from a String" do
      valid_values.each do |valid_value|
        expect(CX.parse_name_code(valid_value)).to eq(valid_value)
      end
    end

    it "allows for lowercase input Strings" do
      valid_values.each do |valid_value|
        expect(CX.parse_name_code(valid_value.downcase)).to eq(valid_value)
      end
    end

    it "allows for mixed case input Strings" do
      valid_values.each do |valid_value|
        expect(CX.parse_name_code(valid_value.capitalize)).to eq(valid_value)
      end
    end

    it "raises an TextParseError if the name_code is not a valid value" do
      expect { CX.parse_name_code("Z") }.to raise_error(TextParseError)
    end

    it "raises an TextParseError if the name_code is nil or empty" do
      expect { CX.parse_name_code(nil) }.to raise_error(TextParseError)
      expect { CX.parse_name_code("") }.to  raise_error(TextParseError)
    end

    # <xs:maxLength value="4"/>
    it "raises an TextParseError if length exceeds 4 characters" do
      expect { CX.parse_name_code("OTHER") }.to raise_error(TextParseError)
    end
  end

  describe "#parse_prefix" do
    # <xs:pattern value="(Ms|Mrs|Mr|Dr)?"/>
    valid_values = ['Ms', 'Mrs', 'Mr', 'Dr']

    it "parses all valid prefix from a String" do
      valid_values.each do |valid_value|
        expect(CX.parse_prefix(valid_value)).to eq(valid_value)
      end
    end

    it "does NOT raise an TextParseError if the prefix is nil or empty" do
      expect { CX.parse_prefix(nil) }.not_to raise_error
      expect { CX.parse_prefix("") }.not_to  raise_error
      expect(CX.parse_prefix("")).to eq("")
    end

    it "raises an TextParseError if the prefix is not a valid value" do
      expect { CX.parse_prefix("Z") }.to raise_error(TextParseError)
    end

    # <xs:maxLength value="3"/>
    it "raises an TextParseError if length exceeds 3 characters" do
      expect { CX.parse_prefix("Miss") }.to raise_error(TextParseError)
    end
  end

  describe "#parse_suffix" do
    # <xs:pattern value="(Jr|Sr|Mr|Md)?"/>
    valid_values = ['Jr', 'Sr', 'Mr', 'Md']

    it "parses a suffix from a String" do
      valid_values.each do |valid_value|
        expect(CX.parse_suffix(valid_value)).to eq(valid_value)
      end
    end

    it "does NOT raise an TextParseError if the suffix is nil or empty" do
      expect { CX.parse_suffix(nil) }.not_to raise_error
      expect { CX.parse_suffix("") }.not_to  raise_error
      expect(CX.parse_suffix("")).to eq("")
    end

    it "raises an TextParseError if the suffix is not a valid value" do
      expect { CX.parse_suffix("Z") }.to raise_error(TextParseError)
    end

    # <xs:maxLength value="2"/>
    it "raises an TextParseError if length exceeds 2 characters" do
      expect { CX.parse_suffix("Jrr") }.to raise_error(TextParseError)
    end
  end

  describe "#parse_phone_type" do
    # <xs:pattern value="FAX|HM|MBL|OTH|WRK"/>
    valid_values = ['FAX', 'HM', 'MBL', 'OTH', 'WRK']

    it "parses a phone_type from a String" do
      valid_values.each do |valid_value|
        expect(CX.parse_phone_type(valid_value)).to eq(valid_value)
      end
    end

    it "allows for lowercase input Strings" do
      valid_values.each do |valid_value|
        expect(CX.parse_phone_type(valid_value.downcase)).to eq(valid_value)
      end
    end

    it "allows for mixed case input Strings" do
      valid_values.each do |valid_value|
        expect(CX.parse_phone_type(valid_value.capitalize)).to eq(valid_value)
      end
    end

    it "raises an TextParseError if the phone_type is not a valid value" do
      expect { CX.parse_phone_type("Z") }.to raise_error(TextParseError)
    end

    it "raises an TextParseError if the phone_type is nil or empty" do
      expect { CX.parse_phone_type(nil) }.to raise_error(TextParseError)
      expect { CX.parse_phone_type("") }.to  raise_error(TextParseError)
    end

    # <xs:maxLength value="3"/>
    it "raises an TextParseError if length exceeds 3 characters" do
      expect { CX.parse_phone_type("HOME") }.to raise_error(TextParseError)
    end
  end

  describe "#parse_phone_number" do
    it "parses a phone_number from a String" do
      # <xs:pattern value="\d{3}-\d{3}-\d{4}"/>
      expect(CX.parse_phone_number("800-555-1212")).to eq("800-555-1212")
      expect(CX.parse_phone_number("480-123-4567")).to eq("480-123-4567")
    end

    it "raises an TextParseError if the phone_number is not a valid value" do
      expect { CX.parse_phone_number("80-555-1212") }.to raise_error(TextParseError)
      expect { CX.parse_phone_number("800-55-1212") }.to raise_error(TextParseError)
      expect { CX.parse_phone_number("800-555-121") }.to raise_error(TextParseError)
      expect { CX.parse_phone_number("800-555-121") }.to raise_error(TextParseError)
      expect { CX.parse_phone_number("800") }.to         raise_error(TextParseError)
      expect { CX.parse_phone_number("555-121") }.to     raise_error(TextParseError)
      expect { CX.parse_phone_number("Z") }.to raise_error(TextParseError)
    end

    it "does NOT raise an TextParseError if the suffix is nil or empty" do
      expect { CX.parse_phone_number(nil) }.not_to raise_error
      expect { CX.parse_phone_number("") }.not_to  raise_error
      expect(CX.parse_phone_number("")).to eq("")
    end

    it "raises an TextParseError if length exceeds 12 characters" do
      expect { CX.parse_suffix("123-456-78901") }.to raise_error(TextParseError)
    end
  end

  describe "#parse_email_type" do
    # <xs:pattern value="HM|OTH|WRK"/>
    valid_values = ['HM', 'OTH', 'WRK']

    it "parses a email_type from a String" do
      valid_values.each do |valid_value|
        expect(CX.parse_email_type(valid_value)).to eq(valid_value)
      end
    end

    it "allows for lowercase input Strings" do
      valid_values.each do |valid_value|
        expect(CX.parse_email_type(valid_value.downcase)).to eq(valid_value)
      end
    end

    it "allows for mixed case input Strings" do
      valid_values.each do |valid_value|
        expect(CX.parse_email_type(valid_value.capitalize)).to eq(valid_value)
      end
    end

    it "raises an TextParseError if the email_type is not a valid value" do
      expect { CX.parse_email_type("Z") }.to raise_error(TextParseError)
    end

    it "raises an TextParseError if the email_type is nil or empty" do
      expect { CX.parse_email_type(nil) }.to raise_error(TextParseError)
      expect { CX.parse_email_type("") }.to  raise_error(TextParseError)
    end

    # <xs:maxLength value="3"/>
    it "raises an TextParseError if length exceeds 3 characters" do
      expect { CX.parse_email_type("HOME") }.to raise_error(TextParseError)
    end
  end

  describe "#parse_year" do
    it "parses a year from a String" do
      expect(CX.parse_year("1999")).to eq("1999")
      expect(CX.parse_year("2000")).to eq("2000")
      expect(CX.parse_year("9999")).to eq("9999")
    end

    it "does NOT raise an TextParseError if the year is nil or empty" do
      expect { CX.parse_year(nil) }.not_to raise_error
      expect { CX.parse_year("") }.not_to  raise_error
      expect(CX.parse_year("")).to eq("")
    end

    it "raises an TextParseError if year begins before 1000 CE" do
      expect { CX.parse_year("0") }.to   raise_error(TextParseError)
      expect { CX.parse_year("1") }.to   raise_error(TextParseError)
      expect { CX.parse_year("99") }.to  raise_error(TextParseError)
      expect { CX.parse_year("999") }.to raise_error(TextParseError)
    end

    it "raises an TextParseError if length exceeds 4 characters" do
      expect { CX.parse_year("10000") }.to raise_error(TextParseError)
    end
  end

  describe "#parse_citizenship_type" do
    valid_values = ['1', '2', '3', '4']

    it "parses a citizenship_type from a String" do
      valid_values.each do |valid_value|
        expect(CX.parse_citizenship_type(valid_value)).to eq(valid_value)
      end
    end

    it "raises an TextParseError if the citizenship_type is not a valid value" do
      expect { CX.parse_citizenship_type("0") }.to raise_error(TextParseError)
      expect { CX.parse_citizenship_type("5") }.to raise_error(TextParseError)
      expect { CX.parse_citizenship_type("Z") }.to raise_error(TextParseError)
    end

    it "raises an TextParseError if the citizenship_type is nil or empty" do
      expect { CX.parse_citizenship_type(nil) }.to raise_error(TextParseError)
      expect { CX.parse_citizenship_type("") }.to  raise_error(TextParseError)
    end

    it "raises an TextParseError if length exceeds 1 character" do
      expect { CX.parse_citizenship_type("22") }.to raise_error(TextParseError)
    end
  end

  describe "#parse_degree" do
    # <xs:pattern value="AS|BA|BComm|BEd|BS|DA|DC|DD|DDS|DEng|DFA|DH|DHA|DMin|DPA|DSN|DVM|DVS|HS|JD|LLD|LLM|MA|MAEd|
    # MArch|MBA|MD|MDS|MDiv|MEE|MEd|MEng|MFA|MIS|MLS|MPA|MPE|MPH|MPd|MPhil|MS|MSEd|MST|MSW|MTh|PhD|PharD|ScD|ThD|UKNW"/>
    it "parses all valid degree_code Strings" do
      valid_values = ['AS','BA','BComm','BEd','BS','DA','DC','DD','DDS','DEng','DFA','DH','DHA','DMin','DPA','DSN','DVM','DVS','HS','JD','LLD','LLM','MA','MAEd','MArch','MBA','MD','MDS','MDiv','MEE','MEd','MEng','MFA','MIS','MLS','MPA','MPE','MPH','MPd','MPhil','MS','MSEd','MST','MSW','MTh','PhD','PharD','ScD','ThD','UKNW']
      valid_values.each do |valid_value|
        expect(CX.parse_degree(valid_value)).to eq(valid_value)
      end
    end

    it "does NOT raise an TextParseError if the degree_code is nil or empty" do
      expect { CX.parse_degree(nil) }.not_to raise_error
      expect { CX.parse_degree("") }.not_to  raise_error
      expect(CX.parse_degree("")).to eq("")
    end

    it "raises an TextParseError if the degree_code is not a valid value" do
      expect { CX.parse_degree("Foo") }.to raise_error(TextParseError)
    end
  end

  describe "#parse_csv_command_line_options" do
    executable = "foo.rb"
    args = ["/some/file.csv"]

    it "sets opt[:sql_filename] to a reasonable default value when none is suppied" do
      opt = CX.parse_csv_command_line_options(executable, args)
      expect(opt[:sql_filename]).to eq("/some/file.sql")
    end

    it "sets opt[:csv_filename] to args[0] when a value is supplied" do
      opt = CX.parse_csv_command_line_options(executable, args)
      expect(opt[:csv_filename]).to eq("/some/file.csv")
    end

    it "allows the caller to specify opt[:sql_filename] on the command line" do
      subject = { sql_filename: "/some/other/file.sql" }
      opt = CX.parse_csv_command_line_options(executable, args, subject)
      expect(opt[:sql_filename]).to eq("/some/other/file.sql")
    end

    it "provides good default CSV parsing options" do
      opt = CX.parse_csv_command_line_options(executable, args)
      expect(opt[:csv_options][:headers]).to eq(:first_row)
      expect(opt[:csv_options][:header_converters]).to eq(:symbol)
      expect(opt[:csv_options][:skip_blanks]).to eq(true)
      expect(opt[:csv_options][:col_sep]).to eq(',')
      expect(opt[:csv_options][:quote_char]).to eq('"')
    end

    it "allows you to override the CSV parsing options" do
      opt = CX.parse_csv_command_line_options(executable, args, csv_options: {col_sep: '|', quote_char: '`'})
      expect(opt[:csv_options][:col_sep]).to eq('|')
      expect(opt[:csv_options][:quote_char]).to eq('`')
    end

    it "exits with code 1 if no csv_filename is provided on the command line" do
      begin
        CX.parse_csv_command_line_options(executable, [])
      rescue SystemExit => e
        expect(e.status).to eq 1 # exited with failure status
      else
        raise "Unexpected Exception found: #{e.class}"
      end
    end
  end

  describe "#error" do
    it "it returns a TextParseError when passed a String" do
      expect(CX.error("foo")).to be_kind_of TextParseError
    end

    it "reformats the message with additional context information" do
      e = CX.error("foo")
      expect(e.message).to include "foo"
      expect(e.message).to match /^ERROR:\s+Line\s+(\d+):\s+.+$/
    end

    it "supports passing Exceptions and maintains type" do
      e1 = NotImplementedError.new "foo"
      e2 = CX.error(e1)
      expect(CX.error(e2)).to be_kind_of NotImplementedError
    end

    it "supports passing Exceptions and maintains message" do
      e1 = NotImplementedError.new "foo"
      e2 = CX.error(e1)
      expect(e2.message).to include e1.message
      expect(e2.message).to match /^ERROR:\s+Line\s+(\d+):\s+.+$/
    end

    it "raises an ArgumentError if passed an unsupported type" do
      expect { CX.error("foo".to_i) }.to raise_error(ArgumentError)
    end
  end

  describe "#warning" do
    it "it returns a TextParseError when passed a String" do
      expect(CX.warning("foo")).to be_kind_of TextParseError
    end

    it "reformats the message with additional context information" do
      e = CX.warning("foo")
      expect(e.message).to include "foo"
      expect(e.message).to match /^WARN:\s+Line\s+(\d+):\s+.+$/
    end

    it "supports passing Exceptions and maintains type" do
      e1 = NotImplementedError.new "foo"
      e2 = CX.warning(e1)
      expect(CX.warning(e2)).to be_kind_of NotImplementedError
    end

    it "supports passing Exceptions and maintains message" do
      e1 = NotImplementedError.new "foo"
      e2 = CX.warning(e1)
      expect(e2.message).to include e1.message
      expect(e2.message).to match /^WARN:\s+Line\s+(\d+):\s+.+$/
    end

    it "raises an ArgumentError if passed an unsupported type" do
      expect { CX.warning("foo".to_i) }.to raise_error(ArgumentError)
    end
  end

end
