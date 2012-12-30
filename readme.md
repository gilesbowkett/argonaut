argonaut: because it helps you ship json
========================================

Argonaut analyzes Mongo collections and describes their contents for you. It's basically `DESCRIBE TABLE` for Mongo.

You might use it if you're facing a large Mongo collection and you want to find out what the data looks like overall. Schemaless data stores give you no guarantees about how best to model them, or what data they contain, and that's information you might want to have.

Likewise, API clients need to use domain logic which corresponds to whatever their app's about. Argonaut gives you an easy way to diagram (in code) the structure of any JSON APIs you consume.

So I'm starting to transform this from a `DESCRIBE TABLE` for Mongo into a `DESCRIBE TABLE` for JSON.

how to analyze a flat file of json with argonaut
------------------------------------------------

`brake argonaut:filesystem:analyze["whatever.json"]`

This is UNFINISHED. Don't even fuck with it.

wtf task
--------

`brake argonaut:filesystem:wtf["whatever.json"]`

This will screendump ongoing object-by-object analyses. These analyses are imperfect and the point of the task is to debug them. Starting to disappear, replaced by tests.

what's an argonaut? is that some kind of ice cream?
---------------------------------------------------

http://en.wikipedia.org/wiki/Argonauts

mongo.yml
---------

currently this code assumes you want to read JSON from Mongo. hoping to change that!

but for now, to specify Mongo credentials, put a file called `mongo.yml` at your
top level.

for instance, if you keep your mangos in Mongo, here's what that file might look like:

    host: mongodb.example.com
    port: 12345
    database: mangos
    user: mangofan12345
    password: p4ssw0rd

note that if your file looks exactly like this then your project is doomed.

mongo rake tasks
----------------

This code started life as part of an ETL system for transforming Mongo data into SQL.

It contains several Rake tasks related to that use case.

`rake argonaut:mongo:generate collection=muppets iterations=2000`

This Rake task creates a report analyzing 2000 records from the `muppets` collection. It presents its report in ASCII form, on the command line. It also creates a `MongoTranslator` file to automatically convert `muppets` data into `Muppet` classes. And it also creates a database migration to support the new `Muppet` class. (I'm not open-sourcing `MongoTranslator` yet, because I'm a little busy, so that stuff might go away.)

`rake argonaut:mongo:describe collection=muppets iterations=2000`

This Rake task performs the same analysis and presents an ASCII report in the terminal, but does not create model or migration files.

ruby-beautifier
---------------

the code generation features of this library use this Ruby beautifier I found, which did not appear to be available as a gem. so it's included as a git submodule.

license
-------

MIT license.

contributing
------------

For the next few weeks, you're way better off sending me an email or a tweet than using GitHub's built-in messaging systems, even pull requests, awesome though they are. Apologies!

How you can reach me:

<img src="http://s3.amazonaws.com/giles/headshots_080410/deep235.jpg">

