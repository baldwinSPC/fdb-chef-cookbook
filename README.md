# Chef cookbook for FoundationDB and FDB SQL Layer

The recipes in this cookbook allow for basic configuration of a
FoundationDB cluster with attached SQL servers.

## Recipes

* ```fdb::client ``` configure a client host to have an fdb.cluster file that points
                     to the cluster's coordinators.

* ```fdb::server``` configure a member of the cluster running the FDB server, optionally
                    as a coordinator.

* ```fdb::sql_layer``` configure a host to run the SQL layer storing data in the cluster.

## Attributes

Configuration of these attributes is made easier with FDB knife commands.

* ```fdb/cluster``` the cluster unique id.

* ```fdb/server``` a list of server process configurations having the following:

  * ```id``` the process id and port number on which it listens.

  * ```coordinator``` this process is a coordinator for the cluster.
