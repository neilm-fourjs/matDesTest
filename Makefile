
export BASE=$(PWD)
export FGLIMAGEPATH=$(BASE):$(BASE)/pics:$(BASE)/pics/gmdi.txt
export FGLRESOURCEPATH=../etc
export FJS_GL_DBGLEV=3
export FGLGBCDIR=$(FGLDIR)/web_utilities/gbc/gbc-clean
export FGLPROFILE=$(BASE)/etc/fglprofile
WC=./webcomponents
PROG=matDesTest
MAIN=$(PROG).42m
GWARUN ?= gwarun
GWABUILDTOOL ?= gwabuildtool

GWABIN=gwa_bin

all: bin$(GENVER)/$(MAIN) bin$(GENVER)/fglprofile bin$(GENVER)/pics distbin/$(PROG)$(GENVER).gar

SOURCE=$(shell find . -name \*.4gl) $(shell find . -name \*.per)

bin$(GENVER)/$(MAIN): $(SOURCE)
	gsmake -t $(PROG) $(PROG)$(GENVER).4pw

distbin/$(PROG)$(GENVER).gar: bin$(GENVER)/$(MAIN)
	gsmake -t $(PROG)$(GENVER) $(PROG)$(GENVER).4pw

clean:
	find . -name \*.42? -delete
	rm -rf $(GWABIN)
	rm -f distbin/$(PROG)$(GENVER).gar
	rm -f distbin/$(PROG)$(GENVER).gwa

bin$(GENVER)/fglprofile:
	cd bin$(GENVER) && ln -s ../etc/fglprofile

bin$(GENVER)/pics:
	cd bin$(GENVER) && ln -s ../pics

run:
	cd bin$(GENVER) && fglrun $(MAIN)

gar.deploy: distbin/$(PROG)$(GENVER).gar
	cd distbin && ./gar_deploy.sh $(PROG)$(GENVER)

gwa.build: all
	$(GWABUILDTOOL) -v --main-module $(MAIN) --output-dir $(GWABIN) --gbc $(FGLGBCDIR) --program-dir ./bin$(GENVER) --extra-asset ./etc/fglprofile --extra-asset ./etc/colour_names.txt --extra-asset ./etc/matDesTest.4st --extra-asset ./etc/default.4ad --webcomponent $(WC)/clock --webcomponent $(WC)/dclock --webcomponent $(WC)/colour --title "Material Design Test V1" 
gwa.run: gwa.build
	cd $(GWABIN) && gwasrv index.html

gwa.dist: gwa.build
	fglgar gwa --gwa $(GWABIN) --output distbin/$(PROG)$(GENVER).gwa

gwa.deploy: gwa.dist
	cd distbin && ./gwa_deploy.sh $(PROG)$(GENVER)

gwa.runapp:
	google-chrome --app=http://localhost/b/gwa/$(PROG)$(GENVER)/index.html
