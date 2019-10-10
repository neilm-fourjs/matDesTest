
PROJ=matDesTest
PROG=materialDesignTest
LIB=../g2_lib
BASE=$(PWD)
TRG=../njm_app_bin

export FGLRESOURCEPATH=$(BASE)/etc
export FGLLDPATH=$(TRG)

all: $(TRG)/$(PROG).42r

$(TRG)/$(PROG).42r: src/*.4gl src/*.per
	gsmake $(PROJ).4pw

update:
	git pull

run: $(TRG)/$(PROG).42r
	cd $(TRG) && fglrun $(PROG).42r

clean:
	gsmake -c $(PROJ).4pw
