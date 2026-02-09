# KualiCo's client library and command-line tool to help interact with KualiCo's cloud APIs.
# Copyright (C) 2014-2015 KualiCo, Inc.

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

require 'net/http'
require 'nokogiri'
require 'tempfile'
require "kuali_toolbox/etl"

# KualiCo Grant and Research Management methods.
module KualiCo::ETL::GRM

  # Parses the <tt>ROLODEX_ID</tt> by column :name and mutates the SQL statement accordingly.
  # @param row [CSV::Row] the CSV Row being parsed
  # @param insert_str [String] the left side of the insert statement (i.e. columns)
  # @param values_str [String] the right side of the insert statement (i.e. values)
  # @param opt [Hash] options Hash will be passed through to {KualiCo::ETL.parse_integer!}.
  # @return [void]
  # @see parse_integer!
  def self.parse_rolodex_id!(row, insert_str, values_str, opt={ name: 'ROLODEX_ID', required: true, length: 6 })
    #   `ROLODEX_ID` decimal(6,0) NOT NULL DEFAULT '0',
    opt[:name]     = "ROLODEX_ID" if opt[:name].nil?
    opt[:required] = true if opt[:required].nil?
    opt[:length]   = 6 if opt[:length].nil?
    KualiCo::ETL::parse_integer! row, insert_str, values_str, opt
  end

  # Parses the <tt>COUNTRY_CODE</tt> by column :name and mutates the SQL statement accordingly.
  # @param row [CSV::Row] the CSV Row being parsed
  # @param insert_str [String] the left side of the insert statement (i.e. columns)
  # @param values_str [String] the right side of the insert statement (i.e. values)
  # @param opt [Hash] options Hash will be passed through to {KualiCo::ETL.parse_string!}.
  # @return [void]
  # @see parse_string!
  def self.parse_country_code!(row, insert_str, values_str, opt={ name: 'COUNTRY_CODE', length: 3 })
    #   `COUNTRY_CODE` char(3) COLLATE utf8_bin DEFAULT NULL,
    opt[:name]   = "COUNTRY_CODE" if opt[:name].nil?
    opt[:length] = 3 if opt[:length].nil?
    KualiCo::ETL::parse_string! row, insert_str, values_str, opt
  end

  # Parses the <tt>STATE</tt> by column :name and mutates the SQL statement accordingly.
  # @param row [CSV::Row] the CSV Row being parsed
  # @param insert_str [String] the left side of the insert statement (i.e. columns)
  # @param values_str [String] the right side of the insert statement (i.e. values)
  # @param opt [Hash] options Hash will be passed through to {KualiCo::ETL.parse_string!}.
  # @return [void]
  # @see parse_string!
  def self.parse_state!(row, insert_str, values_str, opt={ name: 'STATE', length: 30 })
    #   `STATE` varchar(30) COLLATE utf8_bin DEFAULT NULL,
    opt[:name]   = "STATE" if opt[:name].nil?
    opt[:length] = 30 if opt[:length].nil?
    KualiCo::ETL::parse_string! row, insert_str, values_str, opt
  end

  # Parses the <tt>SPONSOR_CODE</tt> by column :name and mutates the SQL statement accordingly.
  # @param row [CSV::Row] the CSV Row being parsed
  # @param insert_str [String] the left side of the insert statement (i.e. columns)
  # @param values_str [String] the right side of the insert statement (i.e. values)
  # @param opt [Hash] options Hash will be passed through to {KualiCo::ETL.parse_string!}.
  # @return [void]
  # @see parse_string!
  def self.parse_sponsor_code!(row, insert_str, values_str, opt={ name: 'SPONSOR_CODE', required: false, length: 6 })
    #   `SPONSOR_CODE` char(6) COLLATE utf8_bin NOT NULL DEFAULT '',
    opt[:name]     = "SPONSOR_CODE" if opt[:name].nil?
    opt[:required] = false if opt[:required].nil?
    opt[:length]   = 6 if opt[:length].nil?
    KualiCo::ETL::parse_string! row, insert_str, values_str, opt
  end

  # Parses the <tt>POSTAL_CODE</tt> by column :name and mutates the SQL statement accordingly.
  # @param row [CSV::Row] the CSV Row being parsed
  # @param insert_str [String] the left side of the insert statement (i.e. columns)
  # @param values_str [String] the right side of the insert statement (i.e. values)
  # @param opt [Hash] options Hash will be passed through to {KualiCo::ETL.parse_string!}.
  # @return [void]
  # @see parse_string!
  def self.parse_postal_code!(row, insert_str, values_str, opt={ name: 'POSTAL_CODE', length: 15 })
    #   `POSTAL_CODE` varchar(15) COLLATE utf8_bin DEFAULT NULL,
    opt[:name]   = "POSTAL_CODE" if opt[:name].nil?
    opt[:length] = 15 if opt[:length].nil?
    KualiCo::ETL::parse_string! row, insert_str, values_str, opt
  end

  # Parses the <tt>OWNED_BY_UNIT</tt> by column :name and mutates the SQL statement accordingly.
  # @param row [CSV::Row] the CSV Row being parsed
  # @param insert_str [String] the left side of the insert statement (i.e. columns)
  # @param values_str [String] the right side of the insert statement (i.e. values)
  # @param opt [Hash] options Hash will be passed through to {KualiCo::ETL.parse_string!}.
  # @return [void]
  # @see parse_string!
  def self.parse_owned_by_unit!(row, insert_str, values_str, opt={ name: 'OWNED_BY_UNIT', required: true, length: 8 })
    #   `OWNED_BY_UNIT` varchar(8) COLLATE utf8_bin NOT NULL,
    opt[:name]     = "OWNED_BY_UNIT" if opt[:name].nil?
    opt[:required] = true if opt[:required].nil?
    opt[:length]   = 8 if opt[:length].nil?
    KualiCo::ETL::parse_string! row, insert_str, values_str, opt
  end

  # Parse an <tt>EMAIL_ADDRESS</tt> from a String.
  # @note The result is validated against a email address RegExp.
  # @param [String] str the String to be parsed.
  # @param [Hash] opt options Hash will be passed through to {KualiCo::ETL.parse_string}.
  # @return [String] the parsed <tt>EMAIL_ADDRESS</tt>.
  # @raise [TextParseError] if the email address is not valid.
  # @see parse_string
  def self.parse_email_address(str, opt={ name: 'EMAIL_ADDRESS', length: 60 })
    #   `EMAIL_ADDRESS` varchar(60) COLLATE utf8_bin DEFAULT NULL,
    opt[:name]         = "EMAIL_ADDRESS" if opt[:name].nil?
    opt[:length]       = 60 if opt[:length].nil?
    opt[:valid_values] = /^(([a-zA-Z0-9_'\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,5}|[0-9]{1,3})(\]?))?$/ if opt[:valid_values].nil?
    return KualiCo::ETL::parse_string str, opt
  end

  # Parses the <tt>EMAIL_ADDRESS</tt> by column :name and mutates the SQL statement accordingly.
  # @param row [CSV::Row] the CSV Row being parsed
  # @param insert_str [String] the left side of the insert statement (i.e. columns)
  # @param values_str [String] the right side of the insert statement (i.e. values)
  # @param opt [Hash] options Hash will be passed through to {parse_email_address}.
  # @return [void]
  # @see parse_email_address
  # @see mutate_sql_stmt!
  def self.parse_email_address!(row, insert_str, values_str, opt={ name: 'EMAIL_ADDRESS' })
    #   `EMAIL_ADDRESS` varchar(60) COLLATE utf8_bin DEFAULT NULL,
    opt[:name] = "EMAIL_ADDRESS" if opt[:name].nil?
    email_address = parse_email_address row[ KualiCo::ETL::to_symbol( opt[:name] ) ]
    KualiCo::ETL::mutate_sql_stmt! insert_str, opt[:name], values_str, email_address
  end

  # Parse a <tt>PRNCPL_ID</tt> from a String.
  # @param [String] str the String to be parsed.
  # @param [Hash] opt options Hash will be passed through to {KualiCo::ETL.parse_string}.
  # @return [String] the parsed <tt>PRNCPL_ID</tt>.
  # @see parse_string
  def self.parse_principal_id(str, opt={ name: 'PRNCPL_ID', required: true, length: 40 })
    #   `PRNCPL_ID` varchar(40) COLLATE utf8_bin NOT NULL DEFAULT '',
    opt[:name]     = "PRNCPL_ID" if opt[:name].nil?
    opt[:required] = true if opt[:required].nil?
    opt[:length]   = 40   if opt[:length].nil?
    KualiCo::ETL::parse_string str, opt
  end

  # Parse a <tt>PRNCPL_NM</tt> from a String.
  # @param [String] str the String to be parsed.
  # @param [Hash] opt options Hash will be passed through to {KualiCo::ETL.parse_string}.
  # @return [String] the parsed <tt>PRNCPL_NM</tt>.
  # @see parse_string
  def self.parse_principal_name(str, opt={ name: 'PRNCPL_NM', required: true, length: 100 })
    #   `PRNCPL_NM` varchar(100) COLLATE utf8_bin NOT NULL,
    opt[:name]     = "PRNCPL_NM" if opt[:name].nil?
    opt[:length]   = 100  if opt[:length].nil?
    opt[:required] = true if opt[:required].nil?
    prncpl_nm = KualiCo::ETL::parse_string str, opt
    unless prncpl_nm =~ /^([a-z0-9\@\.\_\-]+)$/
      raise KualiCo::ETL::error TextParseError.new "Illegal prncpl_nm found: '#{prncpl_nm}'"
    end
    return prncpl_nm
  end

  # Parse an <tt>EMP_STAT_CD</tt> from a String.
  # @param [String] str the String to be parsed.
  # @param [Hash] opt options Hash will be passed through to {KualiCo::ETL.parse_string}.
  # @return [String] the parsed <tt>EMP_STAT_CD</tt>.
  # @raise [TextParseError] if the <tt>EMP_STAT_CD</tt> is not valid.
  # @see parse_string
  def self.parse_emp_stat_cd(str, opt={ name: 'EMP_STAT_CD', valid_values: /^(A|D|L|N|P|R|S|T)$/i })
    #   `EMP_STAT_CD` varchar(40) COLLATE utf8_bin DEFAULT NULL,
    opt[:name]         = "EMP_STAT_CD" if opt[:name].nil?
    opt[:valid_values] = /^(A|D|L|N|P|R|S|T)$/i if opt[:valid_values].nil?
    opt[:required]     = true
    return KualiCo::ETL::parse_flag str, opt
  end

  # Parse an <tt>EMP_TYP_CD</tt> from a String.
  # @param [String] str the String to be parsed.
  # @param [Hash] opt options Hash will be passed through to {KualiCo::ETL.parse_string}.
  # @return [String] the parsed <tt>EMP_TYP_CD</tt>.
  # @raise [TextParseError] if the <tt>EMP_TYP_CD</tt> is not valid.
  # @see parse_string
  def self.parse_emp_typ_cd(str, opt={ name: 'EMP_TYP_CD', valid_values: /^(N|O|P)$/i })
    #   `EMP_TYP_CD` varchar(40) COLLATE utf8_bin DEFAULT NULL,
    opt[:name]         = "EMP_TYP_CD" if opt[:name].nil?
    opt[:valid_values] = /^(N|O|P)$/i if opt[:valid_values].nil?
    opt[:required]     = true
    return KualiCo::ETL::parse_flag str, opt
  end

  # Parse an <tt>ADDR_TYP_CD</tt> from a String.
  # @param [String] str the String to be parsed.
  # @param [Hash] opt options Hash will be passed through to {KualiCo::ETL.parse_string}.
  # @return [String] the parsed <tt>ADDR_TYP_CD</tt>.
  # @raise [TextParseError] if the <tt>ADDR_TYP_CD</tt> is not valid.
  # @see parse_string
  def self.parse_address_type_code(str, opt={ name: 'ADDR_TYP_CD', length: 3, valid_values: /^(HM|OTH|WRK)$/i })
    opt[:name]         = "ADDR_TYP_CD" if opt[:name].nil?
    opt[:length]       = 3 if opt[:length].nil?
    opt[:valid_values] = /^(HM|OTH|WRK)$/i if opt[:valid_values].nil?
    return KualiCo::ETL::parse_flag str, opt
  end

  # Parse a <tt>NM_TYP_CD</tt> from a String.
  # @param [String] str the String to be parsed.
  # @param [Hash] opt options Hash will be passed through to {KualiCo::ETL.parse_string}.
  # @return [String] the parsed <tt>NM_TYP_CD</tt>.
  # @raise [TextParseError] if the <tt>NM_TYP_CD</tt> is not valid.
  # @see parse_string
  def self.parse_name_code(str, opt={ name: 'NM_TYP_CD', length: 4, valid_values: /^(OTH|PRFR|PRM)$/i })
    opt[:name]         = "NM_TYP_CD" if opt[:name].nil?
    opt[:length]       = 4 if opt[:length].nil?
    opt[:valid_values] = /^(OTH|PRFR|PRM)$/i if opt[:valid_values].nil?
    opt[:required]     = true
    return KualiCo::ETL::parse_flag str, opt
  end

  # Parse a <tt>PREFIX_NM</tt> from a String.
  # @param [String] str the String to be parsed.
  # @param [Hash] opt options Hash will be passed through to {KualiCo::ETL.parse_string}.
  # @return [String] the parsed <tt>PREFIX_NM</tt>.
  # @raise [TextParseError] if the <tt>PREFIX_NM</tt> is not valid.
  # @see parse_string
  def self.parse_prefix(str, opt={ name: 'PREFIX_NM', length: 3, valid_values: /^(Ms|Mrs|Mr|Dr)?$/ })
    opt[:name]         = "PREFIX_NM" if opt[:name].nil?
    opt[:length]       = 3 if opt[:length].nil?
    opt[:valid_values] = /^(Ms|Mrs|Mr|Dr)?$/ if opt[:valid_values].nil?
    opt[:upcase]       = false if opt[:upcase].nil?
    return KualiCo::ETL::parse_flag str, opt
  end

  # Parse a <tt>SUFFIX_NM</tt> from a String.
  # @param [String] str the String to be parsed.
  # @param [Hash] opt options Hash will be passed through to {KualiCo::ETL.parse_string}.
  # @return [String] the parsed <tt>SUFFIX_NM</tt>.
  # @raise [TextParseError] if the <tt>SUFFIX_NM</tt> is not valid.
  # @see parse_string
  def self.parse_suffix(str, opt={ name: 'SUFFIX_NM', length: 3, valid_values: /^(Jr|Sr|Mr|Md)?$/ })
    opt[:name]         = "SUFFIX_NM" if opt[:name].nil?
    opt[:length]       = 3 if opt[:length].nil?
    opt[:valid_values] = /^(Jr|Sr|Mr|Md)?$/ if opt[:valid_values].nil?
    opt[:upcase]       = false if opt[:upcase].nil?
    return KualiCo::ETL::parse_flag str, opt
  end

  # Parse a <tt>PHONE_TYP_CD</tt> from a String.
  # @param [String] str the String to be parsed.
  # @param [Hash] opt options Hash will be passed through to {KualiCo::ETL.parse_string}.
  # @return [String] the parsed <tt>PHONE_TYP_CD</tt>.
  # @raise [TextParseError] if the <tt>PHONE_TYP_CD</tt> is not valid.
  # @see parse_string
  def self.parse_phone_type(str, opt={ name: 'PHONE_TYP_CD', length: 3, valid_values: /^(FAX|HM|MBL|OTH|WRK)$/i })
    opt[:name]         = "PHONE_TYP_CD" if opt[:name].nil?
    opt[:length]       = 3 if opt[:length].nil?
    opt[:valid_values] = /^(FAX|HM|MBL|OTH|WRK)$/i if opt[:valid_values].nil?
    return KualiCo::ETL::parse_flag str, opt
  end

  # Parse a <tt>PHONE_NBR</tt> from a String.
  # @param [String] str the String to be parsed.
  # @param [Hash] opt options Hash will be passed through to {KualiCo::ETL.parse_string}.
  # @return [String] the parsed <tt>PHONE_NBR</tt>.
  # @raise [TextParseError] if the <tt>PHONE_NBR</tt> is not valid.
  # @see parse_string
  def self.parse_phone_number(str, opt={ name: 'PHONE_NBR', length: 12, valid_values: /^(\d{3}-\d{3}-\d{4})?$/ })
    opt[:name]         = "PHONE_NBR" if opt[:name].nil?
    opt[:length]       = 12 if opt[:length].nil?
    opt[:valid_values] = /^(\d{3}-\d{3}-\d{4})?$/ if opt[:valid_values].nil?
    return KualiCo::ETL::parse_string str, opt
  end

  # Parse an <tt>EMAIL_TYP_CD</tt> from a String.
  # @param [String] str the String to be parsed.
  # @param [Hash] opt options Hash will be passed through to {KualiCo::ETL.parse_string}.
  # @return [String] the parsed <tt>EMAIL_TYP_CD</tt>.
  # @raise [TextParseError] if the <tt>EMAIL_TYP_CD</tt> is not valid.
  # @see parse_string
  def self.parse_email_type(str, opt={ name: 'EMAIL_TYP_CD', length: 3, valid_values: /^(HM|OTH|WRK)$/i })
    opt[:name]         = "EMAIL_TYP_CD" if opt[:name].nil?
    opt[:length]       = 3 if opt[:length].nil?
    opt[:valid_values] = /^(HM|OTH|WRK)$/i if opt[:valid_values].nil?
    return KualiCo::ETL::parse_flag str, opt
  end

  # Parse a <tt>YEAR</tt> from a String.
  # @param [String] str the String to be parsed.
  # @param [Hash] opt options Hash will be passed through to {KualiCo::ETL.parse_string}.
  # @return [String] the parsed <tt>YEAR</tt>.
  # @raise [TextParseError] if the <tt>YEAR</tt> is not valid.
  # @see parse_string
  def self.parse_year(str, opt={ name: 'YEAR', length: 4, valid_values: /^(\d{4})?$/ })
    opt[:length]       = 4 if opt[:length].nil?
    opt[:valid_values] = /^(\d{4})?$/ if opt[:valid_values].nil?
    return KualiCo::ETL::parse_string str, opt
  end

  # Parse a <tt>CITIZENSHIP_TYPE_CODE</tt> from a String.
  # @param [String] str the String to be parsed.
  # @param [Hash] opt options Hash will be passed through to {KualiCo::ETL.parse_string}.
  # @return [String] the parsed <tt>CITIZENSHIP_TYPE_CODE</tt>.
  # @raise [TextParseError] if the <tt>CITIZENSHIP_TYPE_CODE</tt> is not valid.
  # @see parse_string
  def self.parse_citizenship_type(str, opt={ name: 'CITIZENSHIP_TYPE_CODE', length: 3, valid_values: /^([1-9][0-9]{0,2})$/ })
    opt[:name]         = "CITIZENSHIP_TYPE_CODE" if opt[:name].nil?
    opt[:length]       = 3 if opt[:length].nil?
    opt[:valid_values] = /^([1-9][0-9]{0,2})$/ if opt[:valid_values].nil?
    opt[:default]      = "1" if opt[:default].nil?
    return KualiCo::ETL::parse_flag str, opt
  end

  # Parse a <tt>DEGREE</tt> from a String.
  # @param [String] str the String to be parsed.
  # @param [Hash] opt options Hash will be passed through to {KualiCo::ETL.parse_string}.
  # @return [String] the parsed <tt>DEGREE</tt>.
  # @raise [TextParseError] if the <tt>DEGREE</tt> is not valid.
  # @see parse_string
  def self.parse_degree(str, opt={ name: 'DEGREE', length: 5 })
    opt[:name]         = "DEGREE" if opt[:name].nil?
    opt[:length]       = 5 if opt[:length].nil?
    opt[:valid_values] = /^(AS|BA|BComm|BEd|BS|DA|DC|DD|DDS|DEng|DFA|DH|DHA|DMin|DPA|DSN|DVM|DVS|HS|JD|LLD|LLM|MA|MAEd|MArch|MBA|MD|MDS|MDiv|MEE|MEd|MEng|MFA|MIS|MLS|MPA|MPE|MPH|MPd|MPhil|MS|MSEd|MST|MSW|MTh|PhD|PharD|ScD|ThD|UKNW)?$/ if opt[:valid_values].nil?
    opt[:upcase]       = false if opt[:upcase].nil?
    return KualiCo::ETL::parse_flag str, opt
  end

  # Parse an <tt>ACTV_IND</tt> from a String.
  # @note Designed specifically for <tt>ACTV_IND</tt>, but could be used on *any* fields that matches <tt>(Y|N)</tt>.
  # @param [String] str the String to be parsed.
  # @param [Hash] opt options Hash will be passed through to {KualiCo::ETL.parse_string}.
  # @return [String] the parsed <tt>ACTV_IND</tt>.
  # @raise [TextParseError] if the <tt>ACTV_IND</tt> is not valid.
  # @see parse_string
  def self.parse_actv_ind(str, opt={ name: 'ACTV_IND', default: 'Y', valid_values: /^(Y|N)$/i })
    #   `ACTV_IND` varchar(1) COLLATE utf8_bin DEFAULT 'Y',
    opt[:name]         = "ACTV_IND" if opt[:name].nil?
    opt[:default]      = "Y" if opt[:default].nil?
    opt[:valid_values] = /^(Y|N)$/i if opt[:valid_values].nil?
    return KualiCo::ETL::parse_flag str, opt
  end

  # Parses the <tt>ACTV_IND</tt> by column :name and mutates the SQL statement accordingly.
  # @note Designed specifically for <tt>ACTV_IND</tt>, but could be used on *any* fields that matches <tt>(Y|N)</tt>.
  # @param row [CSV::Row] the CSV Row being parsed
  # @param insert_str [String] the left side of the insert statement (i.e. columns)
  # @param values_str [String] the right side of the insert statement (i.e. values)
  # @param opt [Hash] options Hash will be passed through to {parse_actv_ind}.
  # @return [void]
  # @see parse_actv_ind
  # @see mutate_sql_stmt!
  def self.parse_actv_ind!(row, insert_str, values_str, opt={ name: 'ACTV_IND' })
    #   `ACTV_IND` varchar(1) COLLATE utf8_bin DEFAULT 'Y',
    opt[:name] = "ACTV_IND" if opt[:name].nil?
    actv_ind = parse_actv_ind row[ KualiCo::ETL::to_symbol( opt[:name] ) ]
    KualiCo::ETL::mutate_sql_stmt! insert_str, opt[:name], values_str, actv_ind
  end

  # Performs an XML XSD schema validation using the published schema.
  # @note Any schema validation errors are output to STDOUT via puts.
  # @param xml_filename [String] A path to the XML file to be validated.
  # @return [Boolean] true if no validation errors are found; otherwise false.
  def self.validate_hr_xml(xml_filename)
    ret_val = false
    # validate the resulting XML file against the official XSD schema
    uri = URI 'https://raw.githubusercontent.com/KualiCo/ce-tech-docs/master/v2_0/hrmanifest.xsd'
    Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
      Tempfile.open "hrmanifest.xsd" do |schema|
        request = Net::HTTP::Get.new uri.request_uri
        http.request request do |response|
          response.read_body do |segment|
            schema.write(segment)
          end
        end
        schema.rewind
        xsd = Nokogiri::XML::Schema schema
        doc = Nokogiri::XML File.read xml_filename
        xml_errors = xsd.validate doc
        if xml_errors.empty?
          puts "Congratulations! The XML file passes XSD schema validation! w00t!\n\n"
          ret_val = true
        else
          puts "Sorry, the XML file does NOT pass XSD schema validation!:"
          xml_errors.each do |error|
            puts error.message
          end
        end
      end # schema
    end
    return ret_val
  end

end
