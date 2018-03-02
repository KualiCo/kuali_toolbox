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

# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kuali_toolbox/version'

Gem::Specification.new do |spec|
  spec.name          = "kuali_toolbox"
  spec.version       = KualiCo::VERSION
  spec.authors       = ["KualiCo"]
  spec.email         = ["dpace@kuali.co"]
  spec.summary       = %q{Client library and command-line tools to help interact with KualiCo's cloud APIs.}
  # spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = "http://kualico.github.io/kuali_toolbox/"
  spec.metadata      = { "issue_tracker" => "https://github.com/KualiCo/kuali_toolbox/issues" }
  spec.license       = "AGPL-3.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'builder', '~> 3.2.2'
  spec.add_runtime_dependency 'nokogiri', '~> 1.8.1'
  spec.add_runtime_dependency 'rest-client', '~> 1.7.2'

  spec.required_ruby_version = '>= 1.9'
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0.0"
  # spec.add_development_dependency "simplecov"
  spec.add_development_dependency "codeclimate-test-reporter"
end
