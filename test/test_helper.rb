require "simplecov"
SimpleCov.start

require "test/unit"
require "mocha/test_unit"
require "pry"

require "roger_sassc"

require File.dirname(__FILE__) + "/helpers/fixture_helper"

RogerSassc.append_path "test/fixtures"
