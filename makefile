SHELL := /usr/bin/qsh

LIB ?= COMLOG
OBJPATH := /QSYS.LIB/$(LIB).LIB
OUTPUTCCSID := 1252
BUILD_DIR := ./src/build

SRVPGM_NAME := COMLOG
TESTPGM_NAME := EXLOG

RPGSQL_SRC := ./src/comLog.sqlrpgle ./src/exLog.sqlrpgle
CL_SRC :=

RPGSQL_MODULES := $(OBJPATH)/comLog.MODULE $(OBJPATH)/exLog.MODULE
CL_PROGRAMS :=

.PHONY: all prep link clean info

all: prep $(RPGSQL_MODULES) $(CL_PROGRAMS) link info

info:
	@echo "-------------- INFORMATIONS --------------"
	@liblist
	@echo "-------------- END OF COMPILATION --------------"

prep:
	@echo "Preparing build environment..."
	@test -d $(BUILD_DIR) || mkdir -p $(BUILD_DIR)
	@system "CHKOBJ OBJ($(LIB)) OBJTYPE(*LIB)" > /dev/null 2>&1 || \
	 system "CRTLIB LIB($(LIB)) TYPE(*PROD) TEXT('Common Logger Library')"
	@echo "Preparation done"
#
# RPG / SQLRPGLE to MODULE
#
$(OBJPATH)/%.MODULE: ./src/%.rpgle
	@echo "Compiling RPGLE source $* ..."
	@touch $(BUILD_DIR)/$*-rpgle.txt
	@setccsid $(OUTPUTCCSID) "$(BUILD_DIR)/$*-rpgle.txt"
	@system "CRTSQLRPGI OBJ($(LIB)/$*) SRCSTMF('./src/$*.rpgle') OBJTYPE(*MODULE) REPLACE(*YES) DBGVIEW(*SOURCE) CVTCCSID(*JOB) COMPILEOPT('TGTCCSID(*JOB)') RPGPPOPT(*LVL2) TGTRLS(*PRV)" > $(BUILD_DIR)/$*-rpgle.txt 2>&1
	@echo "$* compiled"

#
# SQLRPGLE to MODULE
#
$(OBJPATH)/%.MODULE: ./src/%.sqlrpgle
	@echo "Compiling SQLRPGLE source $* ..."
	@touch $(BUILD_DIR)/$*-sqlrpgle.txt
	@setccsid $(OUTPUTCCSID) "$(BUILD_DIR)/$*-sqlrpgle.txt"
	@system "CRTSQLRPGI OBJ($(LIB)/$*) SRCSTMF('./src/$*.sqlrpgle') OBJTYPE(*MODULE) REPLACE(*YES) DBGVIEW(*SOURCE) CVTCCSID(*JOB) COMPILEOPT('TGTCCSID(*JOB)') RPGPPOPT(*LVL2) TGTRLS(*PRV)" > $(BUILD_DIR)/$*-sqlrpgle.txt 2>&1
	@echo "$* compiled"

#
# CLLE to PGM
#
$(OBJPATH)/%.PGM: ./src/%.clle
	@echo "Compiling CLLE source $* ..."
	@touch $(BUILD_DIR)/$*-clle.txt
	@setccsid $(OUTPUTCCSID) "$(BUILD_DIR)/$*-clle.txt"
	@system "CRTBNDCL PGM($(LIB)/$*) SRCSTMF('./src/$*.clle') DFTACTGRP(*NO) ACTGRP(*NEW) REPLACE(*YES) TGTRLS(*PRV) DBGVIEW(*SOURCE)" > $(BUILD_DIR)/$*-clle.txt 2>&1
	@echo "$* compiled"

#
# Link service program and sample/test program
#
link: $(OBJPATH)/comLog.MODULE $(OBJPATH)/exLog.MODULE
	@echo "Creating service program $(SRVPGM_NAME) ..."
	@system "CRTSRVPGM SRVPGM($(LIB)/$(SRVPGM_NAME)) MODULE($(LIB)/COMLOG) SRCSTMF('./src/comLog.BND') EXPORT(*SRCFILE) TGTRLS(*PRV) REPLACE(*YES)"  > $(BUILD_DIR)/$*-clle.txt 2>&1
	@echo "Creating test program $(TESTPGM_NAME) ..."
	@system "CRTPGM PGM($(LIB)/$(TESTPGM_NAME)) MODULE($(LIB)/EXLOG) ENTMOD($(LIB)/EXLOG) ACTGRP(QILE) BNDSRVPGM($(LIB)/$(SRVPGM_NAME)) TGTRLS(*PRV) REPLACE(*YES)"
	@echo "Link done"

clean:
	@echo "Cleaning build logs ..."
	@rm -f $(BUILD_DIR)/*.txt