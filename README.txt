== AMEE-Ruby

A gem to provide a Ruby interface to AMEEconnect (http://www.amee.com)

Licensed under the BSD 3-Clause license (See LICENSE.txt for details)

Author: James Smith, James Hetherington, Andrew Hill, Andrew Berkeley

Copyright: Copyright (c) 2008-2011 AMEE UK Ltd

Homepage: http://github.com/AMEE/amee-ruby

Documentation: http://rubydoc.info/gems/amee/frames

== INSTALLATION

1) Install gem
    > sudo gem install amee

== REQUIREMENTS

'Nokogiri' is used for XML parsing, and requires libxml2. See
http://nokogiri.org/tutorials/installing_nokogiri.html for instructions if you
have problems installing.

== IMPORTANT CHANGES when upgrading to 2.2.0 and above

SSL connections are now supported, and are used BY DEFAULT.If you do not want to
use SSL, you can disable it using the ":ssl => false" option to Connection.new, or
by adding "ssl: false" to your amee.yml if you are using Rails.

== IMPORTANT CHANGES when upgrading beyond 2.0.25

If you are using the $amee connection in your Rails apps, this is now deprecated
and will be removed in future releases. See the "Rails" section below for details 
of what you should use instead.

== USAGE

Currently, you can read DataCategories, DataItems and DataItemValues. See 
examples/view_data_*.rb for simple usage examples. You can also get the list
of available Profiles, and create and delete them. See examples/list_profiles.rb
and examples/create_profile.rb for details. You can also load ProfileCategories,
and load, create and update ProfileItems.

The gem will use the AMEE JSON API if the JSON gem is installed on the local
system. Otherwise the XML API will be used.

== SUPPORT
                    Create    Read     Update    Delete
DataCategories         N        Y         N         N
DataItems              N        Y         N         N
DataItemValues         N        Y         N         Y
Profile List           -        Y         -         -
Profiles               Y        -         -         Y
ProfileCategories      -        Y         -         -
 - drilldown           -        Y         -         -
ProfileItems           Y        Y         Y         Y

== INTERACTIVE SHELL

You can use the 'ameesh' app to interactively explore the AMEE data area. Run
'ameesh -u USERNAME -p PASSWORD -s SERVER' to try it out. Source code for this 
tool is in bin/ameesh and lib/amee/shell.rb. Profiles are not accessible through
this interface yet.

== RAILS

This gem can also be used as a Rails plugin. You can either extract it into
vendor/plugins, or use the new-style config.gem command in environment.rb. For
example:

    config.gem "amee", :version => '~> 2.2.0'

If you copy amee.example.yml from the gem source directory to amee.yml in your
app's config directory, a persistent AMEE connection will be available from 
AMEE::Rails#connection, which you can use anywhere. In your controllers, you can
also use the global_amee_connection function to access the same global connection.

    data = AMEE::Data::Category.root(global_amee_connection)

If you do not use this facility, you will have to create your own connection
objects and manage them yourself, which you can do using AMEE::Connection#new

There is a helper for ActiveRecord models which should be linked to an AMEE profile.
By adding:

    has_amee_profile

to your model, and by adding an amee_profile:string field to the model in the
database, an AMEE profile will be automatically created and destroyed with your
model. By overriding the function amee_save in your model, you can store data in
AMEE when your model is saved.

== CACHING

The AMEE::Connection object implements an optional cache for GET requests.

This uses ActiveSupport::Cache, and supports any ActiveSupport::Cache::Store
caching method except for MemCacheStore (which doesn't provide required features).

All GET requests are cached. POST, PUT, or DELETEs will clear the cache for any
path that matches the affected URL. #expire, #expire_matching, and #expire_all
functions are available for manual cache management. Also, all AMEE objects have
and #expire-cache function to clear them and their descendants from the cache.

To enable caching, pass ':cache => :memory_store' to AMEE::Connection.new, or add
'cache: memory_store' to your amee.yml if using Rails. If you want to use the
same caching configuration as your Rails app, you can add 'cache: rails' to 
amee.yml instead. Caching is disabled by default.

== RETRY / TIMEOUT SUPPORT

The AMEE::Connection object can now automatically retry if a request fails due to 
network problems or connection failures. To enable this feature, pass ':retries => 3'
to AMEE::Connection.new, or add 'retries: 3' to your amee.yml if using Rails. You can
change the number of retry attempts, 3 is just used as an example above.

The Connection object also allows a timeout to be set for requests. By default this is
set to 60 seconds, but if you want to provide a different value (30 seconds for 
instance), pass ':timeout => 30' to AMEE::Connection.new, or 'timeout: 30' in amee.yml.

== UPGRADING TO VERSION > 2

There are a few changes to the API exposed by this gem for version 2. The main
ones are:

1) AMEE::Connection#new takes a hash of options instead of an explicit parameter list.
   Whereas before you would have used new(server, username, password, use_json, enable_cache, enable_debug)
   you would now use new(server, username, password, :format => :json, :enable_caching => true, :enable_debug => true)

2) Many get functions take a hash of options instead of explicit date and itemsPerPage parameters.
   get(... , :start_date => {your_date}, :itemsPerPage => 20)

3) total_amount_per_month functions have been replaced with total_amount. There are also
   total_amount_unit and total_amount_per_unit functions which give the units that the total
   amount is in.