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
require 'kuali_toolbox/etl/grm'

GRM  = Rsmart::ETL::GRM
TextParseError = Rsmart::ETL::TextParseError

RSpec.describe "Rsmart::ETL::GRM" do

  describe "#parse_rolodex_id!" do
    #   `ROLODEX_ID` decimal(6,0) NOT NULL DEFAULT '0',

    it "Modifies the insert_str and values_str based on a CSV::Row match" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['rolodex_id'.to_sym], ['123456'], true)
      GRM.parse_rolodex_id!(row, insert_str, values_str)
      expect(insert_str).to eq("ROLODEX_ID,")
      expect(values_str).to eq("123456,")

      insert_str = ""; values_str = "";
      row = CSV::Row.new(['rolodex_id'.to_sym], ['000001'], true)
      GRM.parse_rolodex_id!(row, insert_str, values_str)
      expect(insert_str).to eq("ROLODEX_ID,")
      expect(values_str).to eq("1,")
    end

    it "Raises an TextParseError if nil or empty" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['rolodex_id'.to_sym], [nil], true)
      expect { GRM.parse_rolodex_id!(row, insert_str, values_str) }.to raise_error(TextParseError)
      row = CSV::Row.new(['rolodex_id'.to_sym], [''], true)
      expect { GRM.parse_rolodex_id!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end

    it "Raises an TextParseError if length exceeds 6 characters" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['rolodex_id'.to_sym], ['1234567'], true)
      expect { GRM.parse_rolodex_id!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_country_code!" do
    it "Modifies the insert_str and values_str based on a CSV::Row match" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['country_code'.to_sym], ['USA'], true)
      GRM.parse_country_code!(row, insert_str, values_str)
      expect(insert_str).to eq("COUNTRY_CODE,")
      expect(values_str).to eq("'USA',")
    end

    it "Does not raise an TextParseError if nil or empty" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['country_code'.to_sym], [nil], true)
      expect { GRM.parse_country_code!(row, insert_str, values_str) }.not_to raise_error
      row = CSV::Row.new(['country_code'.to_sym], [''], true)
      expect { GRM.parse_country_code!(row, insert_str, values_str) }.not_to raise_error
    end

    it "Raises an TextParseError if length exceeds 4 characters" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['country_code'.to_sym], ['FOUR'], true)
      expect { GRM.parse_country_code!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_state!" do
    it "Modifies the insert_str and values_str based on a CSV::Row match" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['state'.to_sym], ['Arizona'], true)
      GRM.parse_state!(row, insert_str, values_str)
      expect(insert_str).to eq("STATE,")
      expect(values_str).to eq("'Arizona',")
    end

    it "Does not raise an TextParseError if nil or empty" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['state'.to_sym], [nil], true)
      expect { GRM.parse_state!(row, insert_str, values_str) }.not_to raise_error
      row = CSV::Row.new(['state'.to_sym], [''], true)
      expect { GRM.parse_state!(row, insert_str, values_str) }.not_to raise_error
    end

    it "Raises an TextParseError if length exceeds 30 characters" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['state'.to_sym], ["x" * 31], true)
      expect { GRM.parse_state!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_sponsor_code!" do
    it "Modifies the insert_str and values_str based on a CSV::Row match" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['sponsor_code'.to_sym], ['000001'], true)
      GRM.parse_sponsor_code!(row, insert_str, values_str)
      expect(insert_str).to eq("SPONSOR_CODE,")
      expect(values_str).to eq("'000001',")
    end

    it "does not raise a TextParseError if nil or empty" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['sponsor_code'.to_sym], [nil], true)
      expect { GRM.parse_sponsor_code!(row, insert_str, values_str) }.not_to raise_error
      row = CSV::Row.new(['sponsor_code'.to_sym], [""], true)
      expect { GRM.parse_sponsor_code!(row, insert_str, values_str) }.not_to raise_error
    end

    it "Raises an TextParseError if length exceeds 6 characters" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['sponsor_code'.to_sym], ["x" * 7], true)
      expect { GRM.parse_sponsor_code!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_postal_code!" do
    it "Modifies the insert_str and values_str based on a CSV::Row match" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['postal_code'.to_sym], ['12345-7890'], true)
      GRM.parse_postal_code!(row, insert_str, values_str)
      expect(insert_str).to eq("POSTAL_CODE,")
      expect(values_str).to eq("'12345-7890',")
    end

    it "Does not raise an TextParseError if nil or empty" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['postal_code'.to_sym], [nil], true)
      expect { GRM.parse_postal_code!(row, insert_str, values_str) }.not_to raise_error
      row = CSV::Row.new(['postal_code'.to_sym], [''], true)
      expect { GRM.parse_postal_code!(row, insert_str, values_str) }.not_to raise_error
    end

    it "Raises an TextParseError if length exceeds 15 characters" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['postal_code'.to_sym], ["x" * 16], true)
      expect { GRM.parse_postal_code!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_owned_by_unit!" do
    it "Modifies the insert_str and values_str based on a CSV::Row match" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['owned_by_unit'.to_sym], ['000001'], true)
      GRM.parse_owned_by_unit!(row, insert_str, values_str)
      expect(insert_str).to eq("OWNED_BY_UNIT,")
      expect(values_str).to eq("'000001',")
    end

    it "Raises an TextParseError if nil or empty" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['owned_by_unit'.to_sym], [nil], true)
      expect { GRM.parse_owned_by_unit!(row, insert_str, values_str) }.to raise_error(TextParseError)
      row = CSV::Row.new(['owned_by_unit'.to_sym], [''], true)
      expect { GRM.parse_owned_by_unit!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end

    it "Raises an TextParseError if length exceeds 8 characters" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['owned_by_unit'.to_sym], ["x" * 9], true)
      expect { GRM.parse_owned_by_unit!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_email_address!" do
    it "Modifies the insert_str and values_str based on a CSV::Row match" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['email_address'.to_sym], ['lance@rsmart.com'], true)
      GRM.parse_email_address!(row, insert_str, values_str)
      expect(insert_str).to eq("EMAIL_ADDRESS,")
      expect(values_str).to eq("'lance@rsmart.com',")
    end

    it "Does not raise an TextParseError if nil or empty" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['email_address'.to_sym], [nil], true)
      expect { GRM.parse_email_address!(row, insert_str, values_str) }.not_to raise_error
      row = CSV::Row.new(['email_address'.to_sym], [''], true)
      expect { GRM.parse_email_address!(row, insert_str, values_str) }.not_to raise_error
    end

    it "Raises an TextParseError if length exceeds 60 characters" do
      insert_str = ""; values_str = "";
      valid_sixty_one_char_email_address = "abcedefghijksdhfksjfdsdfsdfsdfsdhsjkhdf@abcdesfsdfsdfsdff.com"
      row = CSV::Row.new(['email_address'.to_sym], [valid_sixty_one_char_email_address], true)
      expect { GRM.parse_email_address!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end

    it "Raises an TextParseError if it does not match the official RFC email address specifications" do
      insert_str = ""; values_str = "";
      row = CSV::Row.new(['email_address'.to_sym], ["foo"], true)
      expect { GRM.parse_email_address!(row, insert_str, values_str) }.to raise_error(TextParseError)
      row = CSV::Row.new(['email_address'.to_sym], ["foo@bar"], true)
      expect { GRM.parse_email_address!(row, insert_str, values_str) }.to raise_error(TextParseError)
      row = CSV::Row.new(['email_address'.to_sym], ["foo@bar."], true)
      expect { GRM.parse_email_address!(row, insert_str, values_str) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_principal_id" do
    it "parses a principal_id from a String" do
      expect(GRM.parse_principal_id("ABCD1234")).to eq("ABCD1234")
    end

    it "raises an TextParseError if the principal_id is nil or empty" do
      expect { GRM.parse_principal_id(nil) }.to raise_error(TextParseError)
      expect { GRM.parse_principal_id("") }.to  raise_error(TextParseError)
    end

    it "raises an TextParseError if length exceeds 40 characters" do
      expect { GRM.parse_principal_id("x" * 41) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_principal_name" do
    it "parses a principal_nm from a String" do
      expect(GRM.parse_principal_name("lspeelmon")).to eq("lspeelmon")
    end

    it "raises an TextParseError if the principal_nm is nil or empty" do
      expect { GRM.parse_principal_name(nil) }.to raise_error(TextParseError)
      expect { GRM.parse_principal_name("") }.to  raise_error(TextParseError)
    end

    it "raises an TextParseError if the principal_nm contains illegal characters" do
      expect { GRM.parse_principal_name("~!#$%^&*()+=") }.to raise_error(TextParseError)
      expect { GRM.parse_principal_name("LANCE@UPPERCASE.COM") }.to raise_error(TextParseError)
    end

    it "raises an TextParseError if length exceeds 100 characters" do
      expect { GRM.parse_principal_name("x" * 101) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_emp_stat_cd" do
    # <xs:maxLength value="1"/>
    # <xs:pattern value="A|D|L|N|P|R|S|T"/>
    valid_values = ['A', 'D', 'L', 'N', 'P', 'R', 'S', 'T']

    it "parses a emp_stat_cd from a String" do
      valid_values.each do |valid_value|
        expect(GRM.parse_emp_stat_cd(valid_value)).to eq(valid_value)
      end
    end

    it "allows for lowercase input Strings" do
      valid_values.each do |valid_value|
        expect(GRM.parse_emp_stat_cd(valid_value.downcase)).to eq(valid_value)
      end
    end

    it "allows for mixed case input Strings" do
      valid_values.each do |valid_value|
        expect(GRM.parse_emp_stat_cd(valid_value.capitalize)).to eq(valid_value)
      end
    end

    it "raises an TextParseError if the emp_typ_cd is not a valid value" do
      expect { GRM.parse_emp_stat_cd("Z") }.to raise_error(TextParseError)
    end

    it "raises an TextParseError if the emp_stat_cd is nil or empty" do
      expect { GRM.parse_emp_stat_cd(nil) }.to raise_error(TextParseError)
      expect { GRM.parse_emp_stat_cd("") }.to  raise_error(TextParseError)
    end

    it "raises an TextParseError if length exceeds 40 characters" do
      expect { GRM.parse_emp_stat_cd("A" * 41) }.to raise_error(TextParseError)
    end
  end

  describe "#parse_emp_typ_cd" do
    # <xs:pattern value="N|O|P"/>
    valid_values = ['N', 'O', 'P']

    it "parses a emp_typ_cd from a String" do
      valid_values.each do |valid_value|
        expect(GRM.parse_emp_typ_cd(valid_value)).to eq(valid_value)
      end
    end

    it "allows for lowercase input Strings" do
      valid_values.each do |valid_value|
        expect(GRM.parse_emp_typ_cd(valid_value.downcase)).to eq(valid_value)
      end
    end

    it "allows for mixed case input Strings" do
      valid_values.each do |valid_value|
        expect(GRM.parse_emp_typ_cd(valid_value.capitalize)).to eq(valid_value)
      end
    end

    it "raises an TextParseError if the emp_typ_cd is not a valid value" do
      expect { GRM.parse_emp_typ_cd("Z") }.to raise_error(TextParseError)
    end

    it "raises an TextParseError if the emp_typ_cd is nil or empty" do
      expect { GRM.parse_emp_typ_cd(nil) }.to raise_error(TextParseError)
      expect { GRM.parse_emp_typ_cd("") }.to  raise_error(TextParseError)
    end

    #  <xs:maxLength value="1"/>
    it "raises an TextParseError if length exceeds 1 character" do
      expect { GRM.parse_emp_typ_cd("NN") }.to raise_error(TextParseError)
    end
  end

  describe "#parse_address_type_code" do
    # <xs:pattern value="HM|OTH|WRK"/>
    valid_values = ['HM', 'OTH', 'WRK']

    it "parses all valid address_type_code from a String" do
      valid_values.each do |valid_value|
        expect(GRM.parse_address_type_code(valid_value)).to eq(valid_value)
      end
    end

    it "allows for lowercase input Strings" do
      valid_values.each do |valid_value|
        expect(GRM.parse_address_type_code(valid_value.downcase)).to eq(valid_value)
      end
    end

    it "allows for mixed case input Strings" do
      valid_values.each do |valid_value|
        expect(GRM.parse_address_type_code(valid_value.capitalize)).to eq(valid_value)
      end
    end

    it "raises an TextParseError if the address_type_code is not a valid value" do
      expect { GRM.parse_address_type_code("Z") }.to raise_error(TextParseError)
    end

    it "raises an TextParseError if the address_type_code is nil or empty" do
      expect { GRM.parse_address_type_code(nil) }.to raise_error(TextParseError)
      expect { GRM.parse_address_type_code("") }.to  raise_error(TextParseError)
    end

    # <xs:maxLength value="3"/>
    it "raises an TextParseError if length exceeds 3 characters" do
      expect { GRM.parse_address_type_code("HOME") }.to raise_error(TextParseError)
    end
  end

  describe "#parse_name_code" do
    # <xs:pattern value="OTH|PRFR|PRM"/>
    valid_values = ['OTH', 'PRFR', 'PRM']

    it "parses a name_code from a String" do
      valid_values.each do |valid_value|
        expect(GRM.parse_name_code(valid_value)).to eq(valid_value)
      end
    end

    it "allows for lowercase input Strings" do
      valid_values.each do |valid_value|
        expect(GRM.parse_name_code(valid_value.downcase)).to eq(valid_value)
      end
    end

    it "allows for mixed case input Strings" do
      valid_values.each do |valid_value|
        expect(GRM.parse_name_code(valid_value.capitalize)).to eq(valid_value)
      end
    end

    it "raises an TextParseError if the name_code is not a valid value" do
      expect { GRM.parse_name_code("Z") }.to raise_error(TextParseError)
    end

    it "raises an TextParseError if the name_code is nil or empty" do
      expect { GRM.parse_name_code(nil) }.to raise_error(TextParseError)
      expect { GRM.parse_name_code("") }.to  raise_error(TextParseError)
    end

    # <xs:maxLength value="4"/>
    it "raises an TextParseError if length exceeds 4 characters" do
      expect { GRM.parse_name_code("OTHER") }.to raise_error(TextParseError)
    end
  end

  describe "#parse_prefix" do
    # <xs:pattern value="(Ms|Mrs|Mr|Dr)?"/>
    valid_values = ['Ms', 'Mrs', 'Mr', 'Dr']

    it "parses all valid prefix from a String" do
      valid_values.each do |valid_value|
        expect(GRM.parse_prefix(valid_value)).to eq(valid_value)
      end
    end

    it "does NOT raise an TextParseError if the prefix is nil or empty" do
      expect { GRM.parse_prefix(nil) }.not_to raise_error
      expect { GRM.parse_prefix("") }.not_to  raise_error
      expect(GRM.parse_prefix("")).to eq("")
    end

    it "raises an TextParseError if the prefix is not a valid value" do
      expect { GRM.parse_prefix("Z") }.to raise_error(TextParseError)
    end

    # <xs:maxLength value="3"/>
    it "raises an TextParseError if length exceeds 3 characters" do
      expect { GRM.parse_prefix("Miss") }.to raise_error(TextParseError)
    end
  end

  describe "#parse_suffix" do
    # <xs:pattern value="(Jr|Sr|Mr|Md)?"/>
    valid_values = ['Jr', 'Sr', 'Mr', 'Md']

    it "parses a suffix from a String" do
      valid_values.each do |valid_value|
        expect(GRM.parse_suffix(valid_value)).to eq(valid_value)
      end
    end

    it "does NOT raise an TextParseError if the suffix is nil or empty" do
      expect { GRM.parse_suffix(nil) }.not_to raise_error
      expect { GRM.parse_suffix("") }.not_to  raise_error
      expect(GRM.parse_suffix("")).to eq("")
    end

    it "raises an TextParseError if the suffix is not a valid value" do
      expect { GRM.parse_suffix("Z") }.to raise_error(TextParseError)
    end

    # <xs:maxLength value="2"/>
    it "raises an TextParseError if length exceeds 2 characters" do
      expect { GRM.parse_suffix("Jrr") }.to raise_error(TextParseError)
    end
  end

  describe "#parse_phone_type" do
    # <xs:pattern value="FAX|HM|MBL|OTH|WRK"/>
    valid_values = ['FAX', 'HM', 'MBL', 'OTH', 'WRK']

    it "parses a phone_type from a String" do
      valid_values.each do |valid_value|
        expect(GRM.parse_phone_type(valid_value)).to eq(valid_value)
      end
    end

    it "allows for lowercase input Strings" do
      valid_values.each do |valid_value|
        expect(GRM.parse_phone_type(valid_value.downcase)).to eq(valid_value)
      end
    end

    it "allows for mixed case input Strings" do
      valid_values.each do |valid_value|
        expect(GRM.parse_phone_type(valid_value.capitalize)).to eq(valid_value)
      end
    end

    it "raises an TextParseError if the phone_type is not a valid value" do
      expect { GRM.parse_phone_type("Z") }.to raise_error(TextParseError)
    end

    it "raises an TextParseError if the phone_type is nil or empty" do
      expect { GRM.parse_phone_type(nil) }.to raise_error(TextParseError)
      expect { GRM.parse_phone_type("") }.to  raise_error(TextParseError)
    end

    # <xs:maxLength value="3"/>
    it "raises an TextParseError if length exceeds 3 characters" do
      expect { GRM.parse_phone_type("HOME") }.to raise_error(TextParseError)
    end
  end

  describe "#parse_phone_number" do
    it "parses a phone_number from a String" do
      # <xs:pattern value="\d{3}-\d{3}-\d{4}"/>
      expect(GRM.parse_phone_number("800-555-1212")).to eq("800-555-1212")
      expect(GRM.parse_phone_number("480-123-4567")).to eq("480-123-4567")
    end

    it "raises an TextParseError if the phone_number is not a valid value" do
      expect { GRM.parse_phone_number("80-555-1212") }.to raise_error(TextParseError)
      expect { GRM.parse_phone_number("800-55-1212") }.to raise_error(TextParseError)
      expect { GRM.parse_phone_number("800-555-121") }.to raise_error(TextParseError)
      expect { GRM.parse_phone_number("800-555-121") }.to raise_error(TextParseError)
      expect { GRM.parse_phone_number("800") }.to         raise_error(TextParseError)
      expect { GRM.parse_phone_number("555-121") }.to     raise_error(TextParseError)
      expect { GRM.parse_phone_number("Z") }.to raise_error(TextParseError)
    end

    it "does NOT raise an TextParseError if the suffix is nil or empty" do
      expect { GRM.parse_phone_number(nil) }.not_to raise_error
      expect { GRM.parse_phone_number("") }.not_to  raise_error
      expect(GRM.parse_phone_number("")).to eq("")
    end

    it "raises an TextParseError if length exceeds 12 characters" do
      expect { GRM.parse_suffix("123-456-78901") }.to raise_error(TextParseError)
    end
  end

  describe "#parse_email_type" do
    # <xs:pattern value="HM|OTH|WRK"/>
    valid_values = ['HM', 'OTH', 'WRK']

    it "parses a email_type from a String" do
      valid_values.each do |valid_value|
        expect(GRM.parse_email_type(valid_value)).to eq(valid_value)
      end
    end

    it "allows for lowercase input Strings" do
      valid_values.each do |valid_value|
        expect(GRM.parse_email_type(valid_value.downcase)).to eq(valid_value)
      end
    end

    it "allows for mixed case input Strings" do
      valid_values.each do |valid_value|
        expect(GRM.parse_email_type(valid_value.capitalize)).to eq(valid_value)
      end
    end

    it "raises an TextParseError if the email_type is not a valid value" do
      expect { GRM.parse_email_type("Z") }.to raise_error(TextParseError)
    end

    it "raises an TextParseError if the email_type is nil or empty" do
      expect { GRM.parse_email_type(nil) }.to raise_error(TextParseError)
      expect { GRM.parse_email_type("") }.to  raise_error(TextParseError)
    end

    # <xs:maxLength value="3"/>
    it "raises an TextParseError if length exceeds 3 characters" do
      expect { GRM.parse_email_type("HOME") }.to raise_error(TextParseError)
    end
  end

  describe "#parse_year" do
    it "parses a year from a String" do
      expect(GRM.parse_year("1999")).to eq("1999")
      expect(GRM.parse_year("2000")).to eq("2000")
      expect(GRM.parse_year("9999")).to eq("9999")
    end

    it "does NOT raise an TextParseError if the year is nil or empty" do
      expect { GRM.parse_year(nil) }.not_to raise_error
      expect { GRM.parse_year("") }.not_to  raise_error
      expect(GRM.parse_year("")).to eq("")
    end

    it "raises an TextParseError if year begins before 1000 CE" do
      expect { GRM.parse_year("0") }.to   raise_error(TextParseError)
      expect { GRM.parse_year("1") }.to   raise_error(TextParseError)
      expect { GRM.parse_year("99") }.to  raise_error(TextParseError)
      expect { GRM.parse_year("999") }.to raise_error(TextParseError)
    end

    it "raises an TextParseError if length exceeds 4 characters" do
      expect { GRM.parse_year("10000") }.to raise_error(TextParseError)
    end
  end

  describe "#parse_citizenship_type" do
    valid_values = ['1', '2', '3', '4']

    it "parses a citizenship_type from a String" do
      valid_values.each do |valid_value|
        expect(GRM.parse_citizenship_type(valid_value)).to eq(valid_value)
      end
    end

    it "raises an TextParseError if the citizenship_type is not a valid value" do
      expect { GRM.parse_citizenship_type("0") }.to raise_error(TextParseError)
      expect { GRM.parse_citizenship_type("6") }.to raise_error(TextParseError)
      expect { GRM.parse_citizenship_type("Z") }.to raise_error(TextParseError)
    end

    it "raises an TextParseError if the citizenship_type is nil or empty" do
      expect { GRM.parse_citizenship_type(nil) }.to raise_error(TextParseError)
      expect { GRM.parse_citizenship_type("") }.to  raise_error(TextParseError)
    end

    it "raises an TextParseError if length exceeds 1 character" do
      expect { GRM.parse_citizenship_type("22") }.to raise_error(TextParseError)
    end
  end

  describe "#parse_degree" do
    # <xs:pattern value="AS|BA|BComm|BEd|BS|DA|DC|DD|DDS|DEng|DFA|DH|DHA|DMin|DPA|DSN|DVM|DVS|HS|JD|LLD|LLM|MA|MAEd|
    # MArch|MBA|MD|MDS|MDiv|MEE|MEd|MEng|MFA|MIS|MLS|MPA|MPE|MPH|MPd|MPhil|MS|MSEd|MST|MSW|MTh|PhD|PharD|ScD|ThD|UKNW"/>
    it "parses all valid degree_code Strings" do
      valid_values = ['AS','BA','BComm','BEd','BS','DA','DC','DD','DDS','DEng','DFA','DH','DHA','DMin','DPA','DSN','DVM','DVS','HS','JD','LLD','LLM','MA','MAEd','MArch','MBA','MD','MDS','MDiv','MEE','MEd','MEng','MFA','MIS','MLS','MPA','MPE','MPH','MPd','MPhil','MS','MSEd','MST','MSW','MTh','PhD','PharD','ScD','ThD','UKNW']
      valid_values.each do |valid_value|
        expect(GRM.parse_degree(valid_value)).to eq(valid_value)
      end
    end

    it "does NOT raise an TextParseError if the degree_code is nil or empty" do
      expect { GRM.parse_degree(nil) }.not_to raise_error
      expect { GRM.parse_degree("") }.not_to  raise_error
      expect(GRM.parse_degree("")).to eq("")
    end

    it "raises an TextParseError if the degree_code is not a valid value" do
      expect { GRM.parse_degree("Foo") }.to raise_error(TextParseError)
    end
  end

end
