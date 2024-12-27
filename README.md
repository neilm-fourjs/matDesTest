# matResTest

A Genero demo for testing various Genero UI features.

# Building
```
$ mkdir git
$ cd git
$ git clone git@bitbucket.org:rldevrldev/matdestest.git    ( ie paste the command copied above )
$ cd matdestest     - this folder should now exist
$ . ./genv          - set the Genero version to use either 321(default) or 401
$ make              - build the application
```


# Running locally
```
$ make run          - run the application
```

This will probably fail with:
```
Program stopped at 'matDesTest.4gl', line number 109.
FORMS statement error number -6300.
Can not connect to GUI: '192.168.200.1:6403': Connection refused.
```
The reason is my GDC 3.2x is running on port 6403 but yours it probably running 6400 ( ie the default port )

To fix this just edit the genv script, find these lines:
```
if [ "$GENVER" = "321" ]; then
  export FGLSERVER=$(who -m | cut -d'(' -f2 | cut -d')' -f1):3
fi
```

Remove the :3 from the end of the line, or if your GDC is running on a different port offset ( from 6400 ) then change it to the correct offset for you.

Then re-run that script: . ./genv

If you want to run Genero V4 then you can download the Genero Desktop Client 4.01 from the www.4js.com and run that ( to run it on a specific port you can add --port <port> ie --port 6404 )


# Running via the GAS

The app is currently already deployed for both 3.21 and 4.01, the deployed versions of that program are:

http://192.168.68.214/g3/ua/r/matDesTest

http://192.168.68.214/g4/ua/r/matDesTest

NOTE: The url is http://<SERVER IP>/<GAS ALIAS>/ua/r/<XCF NAME>


# Deploying

If you want to deploy your own versions you'd have to change name of package and the .xcf file.

You can do that using sed commands, ie:
NOTE: change the 'xxx' to your initials
```
$ sed 's\matDesTest.xcf\matDesTest_xxx.xcf\g' matDesTest321.4pw > matDesTest_xxx321.4pw
$ sed -i 's\matDesTest321\matDesTest_xxx321\g' matDesTest_xxx321.4pw
$ sed 's\matDesTest$(GENVER)\matDesTest_xxx$(GENVER)\g' Makefile > Makefile.xxx
$ make -f Makefile.xxx
$ make -f Makefile.xxx deploy
```
Then run it using:
http://192.168.68.214/<g3 or g4 depending which version you used>/ua/r/matDesTest_xxx

