# matResTest

A Genero demo for testing various Genero UI features.

# Building
```
$ mkdir git
$ cd git
$ git clone git@github.com:neilm-fourjs/matDesTest.git    ( ie paste the command copied above )
$ cd matdestest     - this folder should now exist
$ . ./genv          - set the Genero version to use either 501(default) or 500
$ make              - build the application
```

NOTE: genv assumes Genero products are installed /opt/fourjs or /opt/Genero - if not then you'll have to set the Genero environment yourself.


# Running locally
```
$ make run          - run the application
```

NOTE: You'll need to make sure FGLSERVER is set correctly to run this from the command line.

# Running via the GAS


deploy the gar file from the distbin folder then run using:


The url is http://<SERVER IP>/<GAS ALIAS>/ua/r/<XCF NAME>

