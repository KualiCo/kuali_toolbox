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

end
