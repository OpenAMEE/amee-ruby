# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "amee"
  s.version = "4.1.1"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["James Smith", "James Hetherington", "Andrew Hill", "Andrew Berkeley"]
  s.date = "2011-09-29"
  s.email = "james@floppy.org.uk"
  s.executables = ["ameesh"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.txt"
  ]
  s.files = [
    "CHANGELOG.txt",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.txt",
    "Rakefile",
    "VERSION",
    "amee-ruby.gemspec",
    "amee.example.yml",
    "amee.gemspec",
    "bin/ameesh",
    "cacert.pem",
    "examples/create_profile.rb",
    "examples/create_profile_item.rb",
    "examples/list_profiles.rb",
    "examples/view_data_category.rb",
    "examples/view_data_item.rb",
    "examples/view_profile_item.rb",
    "lib/amee.rb",
    "lib/amee/collection.rb",
    "lib/amee/config.rb",
    "lib/amee/connection.rb",
    "lib/amee/core-extensions/hash.rb",
    "lib/amee/data_category.rb",
    "lib/amee/data_item.rb",
    "lib/amee/data_item_value.rb",
    "lib/amee/data_item_value_history.rb",
    "lib/amee/data_object.rb",
    "lib/amee/drill_down.rb",
    "lib/amee/exceptions.rb",
    "lib/amee/item_definition.rb",
    "lib/amee/item_value_definition.rb",
    "lib/amee/logger.rb",
    "lib/amee/object.rb",
    "lib/amee/pager.rb",
    "lib/amee/parse_helper.rb",
    "lib/amee/profile.rb",
    "lib/amee/profile_category.rb",
    "lib/amee/profile_item.rb",
    "lib/amee/profile_item_value.rb",
    "lib/amee/profile_object.rb",
    "lib/amee/rails.rb",
    "lib/amee/shell.rb",
    "lib/amee/user.rb",
    "lib/amee/v3.rb",
    "lib/amee/v3/collection.rb",
    "lib/amee/v3/connection.rb",
    "lib/amee/v3/item_definition.rb",
    "lib/amee/v3/item_value_definition.rb",
    "lib/amee/v3/item_value_definition_list.rb",
    "lib/amee/v3/meta_helper.rb",
    "lib/amee/v3/return_value_definition.rb",
    "spec/amee_config_spec.rb",
    "spec/amee_spec.rb",
    "spec/cache_spec.rb",
    "spec/connection_spec.rb",
    "spec/data_category_spec.rb",
    "spec/data_item_spec.rb",
    "spec/data_item_value_history_spec.rb",
    "spec/data_item_value_spec.rb",
    "spec/data_object_spec.rb",
    "spec/drill_down_spec.rb",
    "spec/fixtures/AD63A83B4D41.json",
    "spec/fixtures/AD63A83B4D41.xml",
    "spec/fixtures/BD88D30D1214.xml",
    "spec/fixtures/create_item.json",
    "spec/fixtures/create_item.xml",
    "spec/fixtures/data.json",
    "spec/fixtures/data.xml",
    "spec/fixtures/data_home_energy_quantity.xml",
    "spec/fixtures/data_home_energy_quantity_biodiesel.xml",
    "spec/fixtures/data_transport_car_generic_drill_fuel_diesel.xml",
    "spec/fixtures/empty.json",
    "spec/fixtures/empty.xml",
    "spec/fixtures/empty_return_value_definition_list.xml",
    "spec/fixtures/itemdef.xml",
    "spec/fixtures/itemdef_441BF4BEA15B.xml",
    "spec/fixtures/itemdef_no_usages.xml",
    "spec/fixtures/itemdef_one_usage.xml",
    "spec/fixtures/ivdlist.xml",
    "spec/fixtures/ivdlist_BD88D30D1214.xml",
    "spec/fixtures/parse_test.xml",
    "spec/fixtures/rails_config.yml",
    "spec/fixtures/return_value_definition.xml",
    "spec/fixtures/return_value_definition_list.xml",
    "spec/fixtures/v0_data_transport_transport_drill_transportType_Car1.xml",
    "spec/item_definition_spec.rb",
    "spec/item_value_definition_spec.rb",
    "spec/logger_spec.rb",
    "spec/object_spec.rb",
    "spec/parse_helper_spec.rb",
    "spec/profile_category_spec.rb",
    "spec/profile_item_spec.rb",
    "spec/profile_item_value_spec.rb",
    "spec/profile_object_spec.rb",
    "spec/profile_spec.rb",
    "spec/rails_spec.rb",
    "spec/spec.opts",
    "spec/spec_helper.rb",
    "spec/user_spec.rb",
    "spec/v3/connection_spec.rb",
    "spec/v3/item_definition_spec.rb",
    "spec/v3/item_value_definition_spec.rb",
    "spec/v3/return_value_definition_spec.rb"
  ]
  s.homepage = "http://github.com/AMEE/amee-ruby"
  s.licenses = ["BSD 3-Clause"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.10"
  s.summary = "Ruby interface to the AMEE carbon calculator"
  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, ["~> 3.0.10"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<log4r>, [">= 0"])
      s.add_runtime_dependency(%q<nokogiri>, ["~> 1.4.3.1"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_development_dependency(%q<rspec>, ["= 2.6.0"])
      s.add_development_dependency(%q<flexmock>, ["> 0.8.6"])
      s.add_development_dependency(%q<memcache-client>, [">= 0"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, [">= 0"])
      s.add_development_dependency(%q<activerecord>, ["~> 3.0.10"])
    else
      s.add_dependency(%q<activesupport>, ["~> 3.0.10"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<log4r>, [">= 0"])
      s.add_dependency(%q<nokogiri>, ["~> 1.4.3.1"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
      s.add_dependency(%q<rspec>, ["= 2.6.0"])
      s.add_dependency(%q<flexmock>, ["> 0.8.6"])
      s.add_dependency(%q<memcache-client>, [">= 0"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<rdoc>, [">= 0"])
      s.add_dependency(%q<activerecord>, ["~> 3.0.10"])
    end
  else
    s.add_dependency(%q<activesupport>, ["~> 3.0.10"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<log4r>, [">= 0"])
    s.add_dependency(%q<nokogiri>, ["~> 1.4.3.1"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.6.4"])
    s.add_dependency(%q<rspec>, ["= 2.6.0"])
    s.add_dependency(%q<flexmock>, ["> 0.8.6"])
    s.add_dependency(%q<memcache-client>, [">= 0"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<rdoc>, [">= 0"])
    s.add_dependency(%q<activerecord>, ["~> 3.0.10"])
  end
end

