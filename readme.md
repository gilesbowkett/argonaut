argonaut: because it helps you ship json
========================================

Argonaut analyzes Mongo collections and describes their contents for you. It's basically `DESCRIBE TABLE` for Mongo.

You might use it if you're facing a large Mongo collection and you want to find out what the data looks like overall. Schemaless data stores give you no guarantees about how best to model them, or what data they contain, and that's information you might want to have.

I'm hoping to transform this from a `DESCRIBE TABLE` for Mongo into a `DESCRIBE TABLE` for JSON.

what the fuck is an argonaut? is that some kind of ice cream?
-------------------------------------------------------------

http://en.wikipedia.org/wiki/Argonauts

mongo.yml
---------

currently this code assumes you want to read JSON from Mongo. hoping to change that!

but for now, to specify Mongo credentials, put a file called `mongo.yml` at your
top level.

notes from original version
---------------------------

This code started life as part of an ETL system for transforming Mongo data into SQL for
analytics purposes.

It contains several Rake tasks related to that use.

`rake mongo:generate collection=muppets iterations=2000`

This Rake task creates a report analyzing 2000 records from the `muppets` collection. It presents its report in ASCII form, on the command line. It also creates a `MongoTranslator` file to automatically convert `muppets` data into `Muppet` classes. And it also creates a database migration to support the new `Muppet` class. (I'm not open-sourcing `MongoTranslator` yet, because I'm a little busy, so that stuff might go away.)

`rake mongo:describe collection=muppets iterations=2000`

This Rake task performs the same analysis and presents an ASCII report in the terminal, but does not create model or migration files.

`rake mongo:investigate collection=users`

This I will probably destroy. It's a more primitive analyzer which I wrote before the other tasks.

ruby-beautifier
---------------

the code generation features of this library use this Ruby beautifier I found, which did not appear to be available as a gem. so it's included verbatim.

license
-------

MIT license.

