# kuali_toolbox

[![Build Status](https://travis-ci.org/KualiCo/kuali_toolbox.svg?branch=master)](https://travis-ci.org/KualiCo/kuali_toolbox)
[![Test Coverage](https://codeclimate.com/github/KualiCo/kuali_toolbox/badges/coverage.svg)](https://codeclimate.com/github/KualiCo/kuali_toolbox)
[![Gem Version](https://badge.fury.io/rb/kuali_toolbox.svg)](http://badge.fury.io/rb/kuali_toolbox)

Client library and command-line tools to help interact with KualiCo's cloud APIs.

## Installation

To simply install the gem and provide access to the command line tools:

    $ gem install kuali_toolbox

However, if you would like to reuse the our ruby modules in your own ruby program,
add this line to your application's Gemfile:

```ruby
gem 'kuali_toolbox'
```

And then execute:

    $ bundle install

## Usage

### transform_CSV_to_HR_XML

```
Usage: transform_CSV_to_HR_XML [options] csv_file
    -o, --output [xml_file_output]   The file in which the the XML data will be writen (defaults to <csv_file>.xml)
    -s [separator_character],        The character that separates each column of the CSV file.
        --separator
    -q, --quote [quote_character]    The character used to quote fields.
    -e, --email [email_recipients]   Email recipient list that will receive job report status.
    -u, --username [username]        The username used to authenticate to the HR REST API.
    -p, --password [password]        The password used to authenticate to the HR REST API.
    -l, --url [url]                  The full URL of the HR REST API; e.g. https://localhost/kc-dev/hr-import/hrimport/import
    -c, --continue                   Skips bad records and continues processing a CSV file if errors are found.
    -h, --help                       Display this screen
```
> Note: Please be sure to use the [Account_Provisioning_CSV_Template.xlsx](https://github.com/KualiCo/kuali_toolbox/raw/master/Account_Provisioning_CSV_Template.xlsx) template with this tool.

### validate_HR_XML

```
Usage: validate_HR_XML xml_file
    -h, --help                       Display this screen
```

## Contributing

1. Fork it: https://github.com/KualiCo/kuali_toolbox/fork
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Create a new Pull Request

## Pushing a Gem upgrade (must be a project owner on rubygems.org)
1 - update <base>/lib/kuali_toolbox/version.rb with the new version number
2 - gem build kuali_toolbox.gemspec
3 - gem push kuali_toolbox-0.43.gem
