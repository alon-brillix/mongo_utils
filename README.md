All the utilities that connect to mongodb accept these variables to be defined.
Every utility will look for a file __.mongo.env__ in your home directory.
If it is there, it will be sourced, so you can just put these enviroment varibles there:
```
MONGOS=<ip|hostnme>
MONGO_USER=<username>
MONGO_PASSWORD=<password>
MONGO_DB=<database>
```

You can source the file __deploy.sh__ in order to set up the path for both .bash_profile and shell session
