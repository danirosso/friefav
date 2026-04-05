This program uses Postgresql and Ruby to create and manage a database of friends.
It was made with the sole purpose of practicing what I've learned so far with these tools.

It registers a friend by name and asks for their favorite book and music album, gives this
information an id and uses it to build the database.

To run it you will need:
* postgresql
* ruby
* the gem "pg"
* a database owned by you with the name "friefavs", alternatively, you can change these parameters
in db.rb
* Just create the table "friends" with "setup.sql" and everything _should_ run fine

The program itself is made of various functions that get called depending on the
input of the user in the menu, it's very "dynamic", you can check out the list of friends
added (with pagination!), update their preferences, delete an entry, see specfic friends by id
and add new ones.

This program is now being used as a CLI control for webfriefav, a online version of the same concept.
