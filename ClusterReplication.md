# Introduction #
I've been skimming a few papers and searching wikipedia etc. And especially been thinking alot on my own :P
This DB is also fairly interesting:
http://www.couchdbwiki.com/index.php?title=Technical_Overview


# Algorithm #
Anyway what I think will be a good algorithm would be something like this.
The load balancer knows what record ID ranges are stored in which group of nodes.

Every group of nodes, pings eachother every 5 seconds or so to determine which member is alive and how fast they respond.


### Case: New record on Master ###
var person = new Person();
person.name = 'Dude';
person.save();
  * Do the following in parallel (seperate threads)
    * Write to disk:   Table version | TableID | Record ID = LastInsertID+1 | name | Dude
    * Send to buddies:  Own NodeID | TableID | Table version | Record ID | name | Dude

  * Now wait for every buddy to respond with OK | NodeID | TableID | Record ID
    * This waiting should timeout after ( last ping time x 100 ) ms.
    * Which means that with a 1 ms ping, timeout will be 100 ms

  * For each buddy that responds with OK, write to disk: OK | NodeID | TableID | Record ID

  * When at least one alive node has responded with OK do the following in parallel:
    * Write to disk: OK | Own NodeID | TableID | Record ID
    * Send to buddy nodes: OK | Own NodeID | TableID | Record ID
    * Store the changed value in memory

save() is now finished successful.


_Failure handling:_
  * When no nodes respond with OK, something really bad happened and either all buddies died or are way too busy to care.  Retry sending the message at least once?

  * When a node replies with FAIL there could be a change in the same record at the same time (probably small chance but possible). Discard the change (dont set in memory and dont write OK | OwnNode) and return false.


Need a break now.

See images aswell.