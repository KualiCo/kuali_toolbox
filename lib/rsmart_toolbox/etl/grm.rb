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

require "rsmart_toolbox/etl"

module RsmartToolbox::ETL::GRM

  def self.parse_rolodex_id!(row, insert_str, values_str, opt={})
    #   `ROLODEX_ID` decimal(6,0) NOT NULL DEFAULT '0',
    opt[:name]     = "ROLODEX_ID" if opt[:name].nil?
    opt[:required] = true if opt[:required].nil?
    opt[:length]   = 6 if opt[:length].nil?
    RsmartToolbox::ETL::parse_integer! row, insert_str, values_str, opt
  end

  def self.parse_country_code!(row, insert_str, values_str, opt={})
    #   `COUNTRY_CODE` char(3) COLLATE utf8_bin DEFAULT NULL,
    opt[:name]   = "COUNTRY_CODE" if opt[:name].nil?
    opt[:length] = 3 if opt[:length].nil?
    RsmartToolbox::ETL::parse_string! row, insert_str, values_str, opt
  end

  def self.parse_state!(row, insert_str, values_str, opt={})
    #   `STATE` varchar(30) COLLATE utf8_bin DEFAULT NULL,
    opt[:name]   = "STATE" if opt[:name].nil?
    opt[:length] = 30 if opt[:length].nil?
    RsmartToolbox::ETL::parse_string! row, insert_str, values_str, opt
  end

  def self.parse_sponsor_code!(row, insert_str, values_str, opt={})
    #   `SPONSOR_CODE` char(6) COLLATE utf8_bin NOT NULL DEFAULT '',
    opt[:name]     = "SPONSOR_CODE" if opt[:name].nil?
    opt[:required] = true if opt[:required].nil?
    opt[:length]   = 6 if opt[:length].nil?
    RsmartToolbox::ETL::parse_string! row, insert_str, values_str, opt
  end

  def self.parse_postal_code!(row, insert_str, values_str, opt={})
    #   `POSTAL_CODE` varchar(15) COLLATE utf8_bin DEFAULT NULL,
    opt[:name]   = "POSTAL_CODE" if opt[:name].nil?
    opt[:length] = 15 if opt[:length].nil?
    RsmartToolbox::ETL::parse_string! row, insert_str, values_str, opt
  end

  def self.parse_owned_by_unit!(row, insert_str, values_str, opt={})
    #   `OWNED_BY_UNIT` varchar(8) COLLATE utf8_bin NOT NULL,
    opt[:name]     = "OWNED_BY_UNIT" if opt[:name].nil?
    opt[:required] = true if opt[:required].nil?
    opt[:length]   = 8 if opt[:length].nil?
    RsmartToolbox::ETL::parse_string! row, insert_str, values_str, opt
  end

  def self.parse_email_address(str, opt={})
    #   `EMAIL_ADDRESS` varchar(60) COLLATE utf8_bin DEFAULT NULL,
    opt[:name]         = "EMAIL_ADDRESS" if opt[:name].nil?
    opt[:length]       = 60 if opt[:length].nil?
    opt[:valid_values] = /^(([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?))?$/ if opt[:valid_values].nil?
    return RsmartToolbox::ETL::parse_string str, opt
  end

  def self.parse_email_address!(row, insert_str, values_str, opt={})
    #   `EMAIL_ADDRESS` varchar(60) COLLATE utf8_bin DEFAULT NULL,
    opt[:name] = "EMAIL_ADDRESS" if opt[:name].nil?
    email_address = parse_email_address row[ RsmartToolbox::ETL::to_symbol( opt[:name] ) ]
    RsmartToolbox::ETL::mutate_sql_stmt! insert_str, opt[:name], values_str, email_address
  end

  def self.parse_principal_id(str, opt={})
    #   `PRNCPL_ID` varchar(40) COLLATE utf8_bin NOT NULL DEFAULT '',
    opt[:name]     = "PRNCPL_ID" if opt[:name].nil?
    opt[:required] = true if opt[:required].nil?
    opt[:length]   = 40   if opt[:length].nil?
    RsmartToolbox::ETL::parse_string str, opt
  end

  def self.parse_principal_name(str, opt={})
    #   `PRNCPL_NM` varchar(100) COLLATE utf8_bin NOT NULL,
    opt[:name]     = "PRNCPL_NM" if opt[:name].nil?
    opt[:length]   = 100  if opt[:length].nil?
    opt[:required] = true if opt[:required].nil?
    prncpl_nm = RsmartToolbox::ETL::parse_string str, opt
    unless prncpl_nm =~ /^([a-z0-9\@\.\_\-]+)$/
      raise RsmartToolbox::ETL::error TextParseError.new "Illegal prncpl_nm found: '#{prncpl_nm}'"
    end
    return prncpl_nm
  end

  def self.parse_emp_stat_cd(str, opt={})
    #   `EMP_STAT_CD` varchar(40) COLLATE utf8_bin DEFAULT NULL,
    opt[:name]         = "EMP_STAT_CD" if opt[:name].nil?
    opt[:valid_values] = /^(A|D|L|N|P|R|S|T)$/i if opt[:valid_values].nil?
    return RsmartToolbox::ETL::parse_flag str, opt
  end

  def self.parse_emp_typ_cd(str, opt={})
    #   `EMP_TYP_CD` varchar(40) COLLATE utf8_bin DEFAULT NULL,
    opt[:name]         = "EMP_TYP_CD" if opt[:name].nil?
    opt[:valid_values] = /^(N|O|P)$/i if opt[:valid_values].nil?
    return RsmartToolbox::ETL::parse_flag str, opt
  end

  def self.parse_address_type_code(str, opt={})
    # TODO find real column name
    opt[:name]         = "TODO_address_type_code" if opt[:name].nil?
    opt[:length]       = 3 if opt[:length].nil?
    opt[:valid_values] = /^(HM|OTH|WRK)$/i if opt[:valid_values].nil?
    return RsmartToolbox::ETL::parse_flag str, opt
  end

  def self.parse_name_code(str, opt={})
    opt[:name]         = "NM_TYP_CD" if opt[:name].nil?
    opt[:length]       = 4 if opt[:length].nil?
    opt[:valid_values] = /^(OTH|PRFR|PRM)$/i if opt[:valid_values].nil?
    return RsmartToolbox::ETL::parse_flag str, opt
  end

  def self.parse_prefix(str, opt={})
    opt[:name]         = "PREFIX_NM" if opt[:name].nil?
    opt[:length]       = 3 if opt[:length].nil?
    opt[:valid_values] = /^(Ms|Mrs|Mr|Dr)?$/ if opt[:valid_values].nil?
    opt[:upcase]       = false if opt[:upcase].nil?
    return RsmartToolbox::ETL::parse_flag str, opt
  end

  def self.parse_suffix(str, opt={})
    opt[:name]         = "SUFFIX_NM" if opt[:name].nil?
    opt[:length]       = 3 if opt[:length].nil?
    opt[:valid_values] = /^(Jr|Sr|Mr|Md)?$/ if opt[:valid_values].nil?
    opt[:upcase]       = false if opt[:upcase].nil?
    return RsmartToolbox::ETL::parse_flag str, opt
  end

  def self.parse_phone_type(str, opt={})
    # TODO find real column name
    opt[:name]         = "TODO_phone_type" if opt[:name].nil?
    opt[:length]       = 3 if opt[:length].nil?
    opt[:valid_values] = /^(FAX|HM|MBL|OTH|WRK)$/i if opt[:valid_values].nil?
    return RsmartToolbox::ETL::parse_flag str, opt
  end

  def self.parse_phone_number(str, opt={})
    # TODO find real column name
    opt[:name]         = "PHONE_NBR" if opt[:name].nil?
    opt[:length]       = 12 if opt[:length].nil?
    opt[:valid_values] = /^(\d{3}-\d{3}-\d{4})?$/ if opt[:valid_values].nil?
    return RsmartToolbox::ETL::parse_string str, opt
  end

  def self.parse_email_type(str, opt={})
    opt[:name]         = "EMAIL_TYP_CD" if opt[:name].nil?
    opt[:length]       = 3 if opt[:length].nil?
    opt[:valid_values] = /^(HM|OTH|WRK)$/i if opt[:valid_values].nil?
    return RsmartToolbox::ETL::parse_flag str, opt
  end

  def self.parse_year(str, opt={})
    opt[:length]       = 4 if opt[:length].nil?
    opt[:valid_values] = /^(\d{4})?$/ if opt[:valid_values].nil?
    return RsmartToolbox::ETL::parse_string str, opt
  end

  def self.parse_citizenship_type(str, opt={})
    opt[:name]         = "CITIZENSHIP_TYPE_CODE" if opt[:name].nil?
    opt[:valid_values] = /^([1-4])$/ if opt[:valid_values].nil?
    return RsmartToolbox::ETL::parse_flag str, opt
  end

  def self.parse_degree(str, opt={})
    # TODO find real column name
    opt[:name]         = "DEGREE" if opt[:name].nil?
    opt[:length]       = 5 if opt[:length].nil?
    opt[:valid_values] = /^(AS|BA|BComm|BEd|BS|DA|DC|DD|DDS|DEng|DFA|DH|DHA|DMin|DPA|DSN|DVM|DVS|HS|JD|LLD|LLM|MA|MAEd|MArch|MBA|MD|MDS|MDiv|MEE|MEd|MEng|MFA|MIS|MLS|MPA|MPE|MPH|MPd|MPhil|MS|MSEd|MST|MSW|MTh|PhD|PharD|ScD|ThD|UKNW)?$/ if opt[:valid_values].nil?
    opt[:upcase]       = false if opt[:upcase].nil?
    return RsmartToolbox::ETL::parse_flag str, opt
  end

end
