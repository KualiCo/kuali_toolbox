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

module Rsmart::ETL

  class TextParseError < StandardError
  end

  # @param [String, Exception] e the error to handle
  # @return [Exception] an Exception with a message formatted with $INPUT_LINE_NUMBER.
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

  # @param [String, Exception] e the warning to handle
  # @return [Exception] an Exception with a message formatted with $INPUT_LINE_NUMBER.
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

  # @param [String, #match] subject used for validity checking.
  # @param [Array<Object>, Regexp] valid_values all of the possible valid values.
  # @option opt [Boolean] :case_sensitive performs case sensitive matching
  # @return [Boolean] true if the subject matches valid_values.
  #   FYI valid_values must respond to #casecmp.
  # @raise [ArgumentError] if valid_values is nil or empty.
  # @raise [ArgumentError] case sensitive matching only works for objects
  #   that respond to #casecmp; primarily String objects.
  def self.valid_value(subject, valid_values, opt={})
    raise ArgumentError, "valid_values must not be nil!" if valid_values.nil?
    if valid_values.kind_of? Regexp
      return true if subject =~ valid_values
    end
    if valid_values.kind_of? Array
      raise ArgumentError, "valid_values must have at least one element!" unless valid_values.length > 0
      if opt[:case_sensitive] == false # case insensitive comparison requested
        raise ArgumentError, "Object must respond to #casecmp" unless subject.respond_to? 'casecmp'
        valid_values.each do |valid_value|
          return true if valid_value.casecmp(subject) == 0
        end
      end
      return true if valid_values.include? subject # default to == equality
    end
    return false
  end

  # @param [String] str String to be matched against well known boolean patterns.
  # @option opt [Boolean] :default the default return value if str is empty.
  # @return [Boolean] the result of matching the str input against well known boolean patterns.
  # @raise [TextParseError] if none of the known boolean patterns could be matched.
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
    raise Rsmart::ETL::error TextParseError.new "invalid value for Boolean: '#{str}'"
  end

  # @param [String] str the String to be encoded and invalid characters replaced with valid characters.
  # @option opt [String] :encoding the character encoding to use.
  # @return [String] the result of encoding the String and replacing invalid characters with valid characters.
  def self.encode(str, opt={ encoding: "UTF-8" } )
    opt[:encoding] = "UTF-8" if opt[:encoding].nil?
    str.encode( opt[:encoding], :invalid => :replace,
                :undef => :replace, :replace => "" )
  end

  # Matches the MRI CSV specification:
  # The header String is downcased, spaces are replaced with underscores,
  # non-word characters are dropped, and finally to_sym() is called.
  # @param [String] str the String to be symbolized.
  # @return [Symbol] String is downcased, spaces are replaced with underscores,
  #   non-word characters are dropped
  # @raise [ArgumentError] if str is nil or empty.
  def self.to_symbol(str)
    raise ArgumentError, "Illegal symbol name: '#{str}'" if str.nil? || str.empty?
    encode( str.downcase.gsub(/\s+/, "_").gsub(/\W+/, "") ).to_sym
  end

  # Mutates insert_str and values_str with column_name and value respectively.
  # Proper SQL value quoting will be performed based on object type.
  # @param [String] insert_str the left side of the insert statement (i.e. columns)
  # @param [String] column_name the column name to append to insert_str.
  # @param [String] values_str the right side of the insert statement (i.e. values)
  # @param [Object] value the value to append to values_str. Must respond to #to_s.
  # @return [void]
  def self.mutate_sql_stmt!(insert_str, column_name, values_str, value)
    insert_str.concat "#{column_name.upcase},"
    # TODO what are all of the valid types that should not be quoted?
    if value.kind_of? Integer
      values_str.concat "#{value},"
    else
      values_str.concat "'#{value}',"
    end
    return nil
  end

  # Prepares a String for a SQL statement where single quotes need to be escaped.
  # @param [String] str the String to be escaped.
  # @return [String, nil] the resulting String with single quotes escaped with a backslash.
  #   If a nil is passed, nil is returned.
  def self.escape_single_quotes(str)
    if str.nil?
      return nil
    end
    return str.to_s.gsub("'", "\\\\'")
  end

  # @param [String] str the String to be parsed.
  # @option opt [String, #to_s] :default the default return value if str is empty. Must respond to #to_s
  # @option opt [Boolean] :escape_single_quotes escape single quote characters.
  # @option opt [Integer] :length raise a TextParseError if str.length > :length.
  # @option opt [String] :name the name of the field being parsed. Used only for error handling.
  # @option opt [Boolean] :required raise a TextParseError if str is empty.
  # @option opt [Boolean] :strict strict length checking will produce errors instead of warnings.
  # @option opt [Array<Object>, Regexp] :valid_values all of the possible valid values.
  # @return [String] the parsed results. nil or empty inputs will return the empty String by default(i.e. '').
  # @raise [TextParseError] if the field is :required and found to be empty.
  # @raise [TextParseError] if str.length > :length && :strict
  # @raise [TextParseError] if str does not match :valid_values
  # @example nil or empty inputs will return the empty String by default
  #   '' == parse_string(nil) && '' == parse_string('')
  # @see valid_value
  # @see escape_single_quotes
  def self.parse_string(str, opt={ strict: true, required: false, escape_single_quotes: true })
    opt[:strict] = true if opt[:strict].nil?
    opt[:escape_single_quotes] = true if opt[:escape_single_quotes].nil?
    retval = encode str.to_s.strip
    if opt[:required] && retval.empty?
      raise Rsmart::ETL::error TextParseError.new "Required data element '#{opt[:name]}' not found: '#{str}'"
    end
    if opt[:default] && retval.empty?
      retval = opt[:default].to_s
    end
    if opt[:length] && retval.length > opt[:length].to_i
      detail = "#{opt[:name]}.length > #{opt[:length]}: '#{str}'-->'#{str[0..(opt[:length] - 1)]}'"
      if opt[:strict]
        raise Rsmart::ETL::error TextParseError.new "Data exceeds maximum field length: #{detail}"
      end
      Rsmart::ETL::warning "Data will be truncated: #{detail}"
    end
    if opt[:valid_values] && ! valid_value(retval, opt[:valid_values], opt)
      raise Rsmart::ETL::error TextParseError.new "Illegal #{opt[:name]}: value '#{str}' not found in: #{opt[:valid_values]}"
    end
    if opt[:escape_single_quotes]
      retval = escape_single_quotes retval
    end
    return retval
  end

  # Helper method which finds the value by column :name and mutates the SQL statement accordingly.
  # @param [CSV::Row] row the CSV Row being parsed
  # @param [String] insert_str the left side of the insert statement (i.e. columns)
  # @param [String] values_str the right side of the insert statement (i.e. values)
  # @param [Hash] opt options Hash will be passed through to #parse_string.
  # @option opt [String] :name the name of the field being parsed. Required.
  # @return [void]
  # @raise [ArgumentError] :name is required.
  # @see parse_string
  # @see mutate_sql_stmt!
  def self.parse_string!(row, insert_str, values_str, opt={})
    raise ArgumentError, "opt[:name] is required!" unless opt[:name]
    str = parse_string( row[ to_symbol( opt[:name] ) ], opt )
    mutate_sql_stmt! insert_str, opt[:name], values_str, str
  end

  # Parse an Integer from a String.
  # @note Note the behavioral difference versus #to_i.
  # @param [String] str the String to be parsed.
  # @param [Hash] opt options Hash will be passed through to #parse_string.
  # @return [Integer, nil] the parsed Integer. nil or empty inputs will return nil by default.
  # @example Unlike #to_i, nil or empty inputs will return nil by default
  #   nil == parse_integer(nil) && nil == parse_integer('') && 0 != parse_integer(nil)
  # @see parse_string
  def self.parse_integer(str, opt={})
    s = parse_string str, opt
    if s.empty?
      return nil;
    else
      return s.to_i
    end
  end

  # Helper method which finds the value by column :name and mutates the SQL statement accordingly.
  # @param [CSV::Row] row the CSV Row being parsed
  # @param [String] insert_str the left side of the insert statement (i.e. columns)
  # @param [String] values_str the right side of the insert statement (i.e. values)
  # @param [Hash] opt options Hash will be passed through to #parse_integer.
  # @option opt [String] :name the name of the field being parsed. Required.
  # @return [void]
  # @raise [ArgumentError] :name is required.
  # @see parse_integer
  # @see mutate_sql_stmt!
  def self.parse_integer!(row, insert_str, values_str, opt={})
    raise ArgumentError, "opt[:name] is required!" unless opt[:name]
    i = parse_integer( row[ to_symbol( opt[:name] ) ], opt )
    mutate_sql_stmt! insert_str, opt[:name], values_str, i
  end

  # Parse a Float from a String.
  # @note Note the behavioral difference versus #to_f.
  # @param [String] str the String to be parsed.
  # @param [Hash] opt options Hash will be passed through to #parse_string.
  # @return [Float, nil] the parsed Float. nil or empty inputs will return nil by default.
  # @example Unlike #to_f, nil or empty inputs will return nil by default
  #   nil == parse_float(nil) && nil == parse_float('') && 0.0 != parse_float(nil)
  # @see parse_string
  def self.parse_float(str, opt={})
    s = parse_string str, opt
    if s.empty?
      return nil;
    else
      return s.to_f
    end
  end

  # Useful for parsing "flag" like values; i.e. usually single characters.
  # @param [String] str the String to be parsed.
  # @param [Hash] opt options Hash will be passed through to #parse_string.
  # @option opt [Integer] :length the maximum supported length of the field.
  # @option opt [Boolean] :upcase if true upcase the results.
  # @return [String] the parsed "flag".
  # @see parse_string
  def self.parse_flag(str, opt={ length: 1, upcase: true })
    opt[:length] = 1 if opt[:length].nil?
    opt[:upcase] = true if opt[:upcase].nil?
    retval = parse_string str, opt
    retval = retval.upcase if opt[:upcase] == true
    return retval
  end

  # Parse common command line options for CSV --> SQL transformations.
  # @param [String] executable the name of the script from which we are executing. See example.
  # @param [Array<String>] args the command line args.
  # @option opt [String] :csv_filename the input file from which the CSV will be read.
  #   Defaults to the first element of args Array.
  # @option opt [String] :sql_filename the output file to which the SQL will be written.
  # @option opt [Hash] :csv_options the options that will be used by the CSV parser.
  # @return [Hash] a Hash containing the parsed command line results.
  # @example The most common usage:
  #   opt = Rsmart::ETL.parse_csv_command_line_options (File.basename $0), ARGF.argv
  def self.parse_csv_command_line_options(
      executable, args, opt={ csv_options: { headers: :first_row,
                                             header_converters: :symbol,
                                             skip_blanks: true,
                                             col_sep: ",",
                                             quote_char: '"'
                                             }
                              } )
    optparse = OptionParser.new do |opts|
      opts.banner = "Usage: #{executable} [options] csv_file"
      opts.on( '-o [sql_file_output]' ,'--output [sql_file_output]', 'The file the SQL data will be writen to... (defaults to <csv_file>.sql)') do |f|
        opt[:sql_filename] = f
      end
      opts.on( '-s [separator_character]' ,'--separator [separator_character]', 'The character that separates each column of the CSV file.') do |s|
        opt[:csv_options][:col_sep] = s
      end
      opts.on( '-q [quote_character]' ,'--quote [quote_character]', 'The character used to quote fields.') do |q|
        opt[:csv_options][:quote_char] = q
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
