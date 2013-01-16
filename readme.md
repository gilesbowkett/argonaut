argonaut: because it helps you ship json
========================================

Argonaut analyzes collections of JSON data and describes their contents for you. It started life as `DESCRIBE TABLE` for Mongo, and now also supports JSON from flat files.

You might use it if you're facing a large Mongo collection and you want to find out what the data looks like overall. Schemaless data stores give you no guarantees about how best to model them, or what data they contain, and that's information you might want to have.

Likewise, API clients need to use domain logic which corresponds to whatever their app's about. Tightly coupling the design of your application to the design of an API which your application consumes is, in my opinion, a mistake. Argonaut gives you an easy way to map the structure of any JSON APIs you consume, and make informed decisions about how you consume them.

work in progress
----------------

This is very much alpha software in pre-release condition. It's extracted from production code, but the extraction's unfinished and I've changed the scope of the project. The specs are a work in progress as well.

how to analyze a flat file of json with argonaut
------------------------------------------------

`brake argonaut:filesystem:analyze["whatever.json"]`

This is unfinished. It produces accurate schemas of arbitrarily nested JSON objects, but they look messy, and I don't currently do anything to reconcile differences in subtree schemas. In other words, given two trees:

    1. {foo: "bar", baz: {qu: "ux"}}
    2. {foo: 123, baz: {quux: "quux"}}

The code will notice that `foo` lacks a consistent data type, but not that `baz` does. (I think.) It will also trigger very many errors which mention schema inconsistency, but which, in my opinion, do not actually come from schema inconsistency. (Irony.) 

wtf task
--------

`brake argonaut:filesystem:wtf["whatever.json"]`

This will screendump ongoing object-by-object analyses. Debugging tool. Starting to disappear, replaced by tests.

what's an argonaut? is that some kind of ice cream?
---------------------------------------------------

http://en.wikipedia.org/wiki/Argonauts

mongo.yml
---------

originally this code assumed users want to read JSON from Mongo.

no longer the focus of the codebase, but, if you want to specify Mongo credentials, use a file called `mongo.yml`.

for instance, if you run a social network about tropical fruit, and you decided to keep your mangos in Mongo, here's what that file might look like:

    host: mongodb.example.com
    port: 12345
    database: mangos
    user: mangofan12345
    password: p4ssw0rd

(note that if your file looks exactly like this then your project is doomed.)

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

For the next few weeks, for reasons that I hope will later become obvious, you're way better off sending me an email or a tweet than using GitHub's built-in messaging systems, even pull requests, awesome though they are. Apologies!

How you can reach me:

<img src="http://s3.amazonaws.com/giles/headshots_080410/deep235.jpg">

