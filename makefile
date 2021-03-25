
PROJ=matDesTest
BASE=$(PWD)
TRG=../njm_app_bin

export FGLRESOURCEPATH=$(BASE)/etc

export GENVER=400

BIN = ../njm_app_bin
SRC = ./src
lib = g2_lib
prg_src = $(wildcard src/*.4gl)
prg_per = $(wildcard src/*.per)

include ./Make_g4.inc

#all: $(TRG)/$(PROG).42r

#$(TRG)/$(PROG).42r: src/*.4gl src/*.per
#	gsmake $(PROJ).4pw

update:
	git pull

run: $(TRG)/$(PROJ).42m
	cd $(TRG) && fglrun $(PROJ)

#clean:
#	gsmake -c $(PROJ).4pw
