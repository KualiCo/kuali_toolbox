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

require "rsmart_toolbox"

module RsmartToolbox::ETL

  class TextParseError < StandardError
  end

  # Responds to String or Exception.
  def self.error(e)
    if e.kind_of? String
      # default to TextParseError
      return TextParseError.new "ERROR: Line #{$INPUT_LINE_NUMBER}: #{e}"
    end
    if e.kind_of? Exception
      return e.exception "ERROR: Line #{$INPUT_LINE_NUMBER}: #{e}"
    end
    raise ArgumentError, "Unsupported error type: #{e.class}"
  end

  # Responds to String or Exception.
  def self.warning(e)
    if e.kind_of? String
      # default to TextParseError
      return TextParseError.new "WARN:  Line #{$INPUT_LINE_NUMBER}: #{e}"
    end
    if e.kind_of? Exception
      return e.exception "WARN:  Line #{$INPUT_LINE_NUMBER}: #{e}"
    end
    raise ArgumentError, "Unsupported error type: #{e.class}"
  end

  # Test to see if subject is a member of valid_values Array
  def self.valid_value(subject, valid_values, opt={})
    raise ArgumentError, "valid_values must not be nil!" if valid_values.nil?
    if valid_values.kind_of? Regexp
      return true if subject =~ valid_values
    end
    if valid_values.kind_of? Array
      raise ArgumentError, "valid_values must have at least one element!" unless valid_values.length > 0
      if opt[:case_sensitive] == false # case insensitive comparison requested
        raise ArgumentError, "case_sensitive only supported for Strings!" unless subject.kind_of?(String)
        valid_values.each do |valid_value|
          return true if valid_value.casecmp(subject) == 0
        end
      end
      return true if valid_values.include? subject # default to == equality
    end
    return false
  end

  def self.parse_boolean(str, opt={})
    return true  if str == true
    return false if str == false
    b = parse_string str, opt
    return true  if b =~ /^(active|a|true|t|yes|y|1)$/i
    return false if b =~ /^(inactive|i|false|f|no|n|0)$/i
    if b.empty? && !opt[:default].nil?
      return opt[:default]
    end
    if b.empty?
      return nil
    end
    raise RsmartToolbox::ETL::error TextParseError.new "invalid value for Boolean: '#{str}'"
  end

  # Simply here to help ensure we consistently apply the same encoding options.
  def self.encode(str, opt={} )
    opt[:encoding] = "UTF-8" if opt[:encoding].nil?
    str.encode( opt[:encoding], :invalid => :replace,
                :undef => :replace, :replace => "" )
  end

  # Matches MRI CSV specification:
  # The header String is downcased, spaces are replaced with underscores,
  # non-word characters are dropped, and finally to_sym() is called.
  def self.to_symbol(str)
    raise ArgumentError, "Illegal symbol name: '#{str}'" if str.nil? || str.empty?
    encode( str.downcase.gsub(/\s+/, "_").gsub(/\W+/, "") ).to_sym
  end

  # DRY up some common string manipulation
  def self.mutate_sql_stmt!(insert_str, column_name, values_str, value)
    insert_str.concat "#{column_name.upcase},"
    # TODO what are all of the valid types that should not be quoted?
    if value.kind_of? Integer
      values_str.concat "#{value},"
    else
      values_str.concat "'#{value}',"
    end
  end

  def self.escape_single_quotes(str)
    if str.nil?
      return nil
    end
    return str.to_s.gsub("'", "\\\\'")
  end

  def self.parse_string(str, opt={})
    opt[:strict]   = true if opt[:strict].nil?
    retval = encode str.to_s.strip
    if opt[:required] && retval.empty?
      raise RsmartToolbox::ETL::error TextParseError.new "Required data element '#{opt[:name]}' not found: '#{str}'"
    end
    if opt[:default] && retval.empty?
      retval = opt[:default]
    end
    if opt[:length] && retval.length > opt[:length].to_i
      detail = "#{opt[:name]}.length > #{opt[:length]}: '#{str}'-->'#{str[0..(opt[:length] - 1)]}'"
      if opt[:strict]
        raise RsmartToolbox::ETL::error TextParseError.new "Data exceeds maximum field length: #{detail}"
      end
      RsmartToolbox::ETL::warning "Data will be truncated: #{detail}"
    end
    if opt[:valid_values] && ! valid_value(retval, opt[:valid_values], opt)
      raise RsmartToolbox::ETL::error TextParseError.new "Illegal #{opt[:name]}: value '#{str}' not found in: #{opt[:valid_values]}"
    end
    return escape_single_quotes retval
  end

  def self.parse_string!(row, insert_str, values_str, opt={})
    raise ArgumentError, "opt[:name] is required!" unless opt[:name]
    str = parse_string( row[ to_symbol( opt[:name] ) ], opt )
    mutate_sql_stmt! insert_str, opt[:name], values_str, str
  end

  def self.parse_integer(str, opt={})
    s = parse_string str, opt
    if s.empty?
      return nil;
    else
      return s.to_i
    end
  end

  def self.parse_integer!(row, insert_str, values_str, opt={})
    raise ArgumentError, "opt[:name] is required!" unless opt[:name]
    i = parse_integer( row[ to_symbol( opt[:name] ) ], opt )
    mutate_sql_stmt! insert_str, opt[:name], values_str, i
  end

  def self.parse_float(str, opt={})
    s = parse_string str, opt
    if s.empty?
      return nil;
    else
      return s.to_f
    end
  end

  # Useful for parsing "flag" like values. Always returns upcase for consistency.
  # Assumes :strict :length of 1 by default.
  def self.parse_flag(str, opt={})
    opt[:length] = 1 if opt[:length].nil?
    opt[:upcase] = true if opt[:upcase].nil?
    retval = parse_string str, opt
    retval = retval.upcase if opt[:upcase] == true
    return retval
  end

  # Designed specifically for actv_ind, but could be used on *any*
  # fields that matches /^(Y|N)$/i.
  def self.parse_actv_ind(str, opt={})
    #   `ACTV_IND` varchar(1) COLLATE utf8_bin DEFAULT 'Y',
    opt[:name]         = "actv_ind" if opt[:name].nil?
    opt[:default]      = "Y" if opt[:default].nil?
    opt[:valid_values] = /^(Y|N)$/i if opt[:valid_values].nil?
    return parse_flag str, opt
  end

  # Designed specifically for actv_ind, but could be used on *any*
  # fields that matches /^(Y|N)$/i.
  def self.parse_actv_ind!(row, insert_str, values_str, opt={})
    #   `ACTV_IND` varchar(1) COLLATE utf8_bin DEFAULT 'Y',
    opt[:name] = "actv_ind" if opt[:name].nil?
    actv_ind = RsmartToolbox::ETL::parse_actv_ind row[ to_symbol( opt[:name] ) ]
    RsmartToolbox::ETL::mutate_sql_stmt! insert_str, opt[:name], values_str, actv_ind
  end

  # Parse common command line options for CSV --> SQL transformations.
  def self.parse_csv_command_line_options(
      executable, args, opt={ csv_options: { headers: :first_row,
                                             header_converters: :symbol,
                                             skip_blanks: true,
                                             col_sep: ",", # comma by default
                                             quote_char: '"', # double quote by default
                                             }
                              } )
    optparse = OptionParser.new do |opts|
      opts.banner = "Usage: #{executable} [options] csv_file"
      opts.on( '-o [sql_file_output]' ,'--output [sql_file_output]', 'The file the SQL data will be writen to... (defaults to <csv_file>.sql)') do |f|
        opt[:sql_filename] = f
      end
      opts.on( '-s [separator_character]' ,'--separator [separator_character]', 'The character that separates each column of the CSV file.') do |s|
        opt[:col_sep] = s
      end
      opts.on( '-q [quote_character]' ,'--quote [quote_character]', 'The character used to quote fields.') do |q|
        opt[:quote_char] = q
      end
      opts.on( '-h', '--help', 'Display this screen' ) do
        puts opts
        exit 1
      end

      opt[:csv_filename] = args[0] unless opt[:csv_filename]
      if opt[:csv_filename].nil? || opt[:csv_filename].empty?
        puts opts
        exit 1
      end
    end
    optparse.parse!

    # construct a sensible default ouptput filename
    unless opt[:sql_filename]
      file_extension = File.extname opt[:csv_filename]
      dir_name = File.dirname opt[:csv_filename]
      base_name = File.basename opt[:csv_filename], file_extension
      opt[:sql_filename] = "#{dir_name}/#{base_name}.sql"
    end

    return opt
  end

end
