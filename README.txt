== AMEE-Ruby

A gem to provide a Ruby interface to AMEEconnect (http://www.amee.com)

Licensed under the BSD 3-Clause license (See LICENSE.txt for details)

Author: James Smith, James Hetherington, Andrew Hill, Andrew Berkeley

Copyright: Copyright (c) 2008-2013 AMEE UK Ltd

Homepage: http://github.com/AMEE/amee-ruby

Documentation: http://rubydoc.info/gems/amee/frames

== INSTALLATION

1) Install gem
    > sudo gem install amee

== REQUIREMENTS

If you are using Rails, note that version 4.x of this gem supports Rails 3 apps 
only. If you are using Rails 2, you should stay with version 3.x. See the 'Rails'
section below for more details.

'Nokogiri' is used for XML parsing, and requires libxml2. See
http://nokogiri.org/tutorials/installing_nokogiri.html for instructions if you
have problems installing.

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

This gem can also be used as a Rails plugin.

Rails 2: add the following to environment.rb:
    config.gem "amee", :version => '~> 3.1'

Rails 3: add the following to your Gemfile:
    gem "amee", '~> 4.1'

If you copy amee.example.yml from the gem source directory to amee.yml in your
app's config directory, a persistent AMEE connection will be available from 
AMEE::Rails#connection, which you can use anywhere. In your controllers, you can
also use the global_amee_connection function to access the same global connection.

    data = AMEE::Data::Category.root(global_amee_connection)

If you do not use this facility, you will have to create your own connection
objects and manage them yourself, which you can do using AMEE::Connection#new

Instead of using an amee.yml file, you can set ENV['AMEE_USERNAME'], ENV['AMEE_PASSWORD']
and ENV['AMEE_SERVER'] to achieve the same effect. This is useful for deploying
to environments like Heroku, for instance.

There is a helper for ActiveRecord models which should be linked to an AMEE profile.
By adding:

    has_amee_profile

to your model, and by adding an amee_profile:string field to the model in the
database, an AMEE profile will be automatically created and destroyed with your
model. By overriding the function amee_save in your model, you can store data in
AMEE when your model is saved.

== RETRY / TIMEOUT SUPPORT

The AMEE::Connection object can now automatically retry if a request fails due to 
network problems or connection failures. To enable this feature, pass ':retries => 3'
to AMEE::Connection.new, or add 'retries: 3' to your amee.yml if using Rails. You can
change the number of retry attempts, 3 is just used as an example above.

The Connection object also allows a timeout to be set for requests. By default this is
set to 60 seconds, but if you want to provide a different value (30 seconds for 
instance), pass ':timeout => 30' to AMEE::Connection.new, or 'timeout: 30' in amee.yml.
