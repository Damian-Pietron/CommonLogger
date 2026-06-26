SHELL := /usr/bin/qsh
LIB ?= A510844
objPath := /QSYS.LIB/$(LIB).LIB
OUTPUTCSSID := 1252

include := ./srv/include/comLog.rpgle \
		   ./srv/include/internal.rpgle \


# Compile target
all: prep \
    $(objPath)/comLog.MODULE \
	$(objPath)/exLog.MODULE \
	link


	@echo "--------------INFORMATIONS--------------"
	@liblist
	@echo "--------------END OF COMPILATION--------------"



# Compile SQLRPGLE source files into modules
$(objPath)/%.MODULE: ./src/%.sqlrpgle
	@echo "Compiling $* ..."
	@touch ./src/build/$*-sqlrpgle.txt
	@setccsid $(OUTPUTCSSID) "./src/build/$*-sqlrpgle.txt"
	@system "CRTSQLRPGI OBJ($(LIB)/$*) SRCSTMF('./src/$*.sqlrpgle') OBJTYPE(*MODULE) REPLACE(*YES) DBGVIEW(*SOURCE) CVTCCSID(*JOB) COMPILEOPT('TGTCCSID(*JOB)') RPGPPOPT(*LVL2) TGTRLS(*CURRENT)" > ./src/build/$*-sqlrpgle.txt 2>&1
	@echo "$* (X)"

# Compile RPGLE source files into modules
$(objPath)/%.MODULE: ./src/%.rpgle
	@echo "Compiling $* ..."
	@touch ./src/build/$*-rpgle.txt
	@setccsid $(OUTPUTCSSID) "./src/build/$*-rpgle.txt"
	@system "CRTSQLRPGI OBJ($(LIB)/$*) SRCSTMF('./src/$*.rpgle') OBJTYPE(*MODULE) REPLACE(*YES) DBGVIEW(*SOURCE) CVTCCSID(*JOB) COMPILEOPT('TGTCCSID(*JOB)') RPGPPOPT(*LVL2) TGTRLS(*CURRENT)" > ./src/build/$*-rpgle.txt 2>&1
	@echo "$* (X)"

# Compile CLLE source files into programs
$(objPath)/%.PGM: ./src/%.clle
	@echo "Compiling $* ..."
	@touch ./src/build/$*-clle.txt
	@setccsid $(OUTPUTCSSID) "./src/build/$*-clle.txt"
	@system "CRTBNDCL PGM($(LIB)/$*) SRCSTMF('./src/$*.clle') DFTACTGRP(*NO) REPLACE(*YES) TGTRLS(*CURRENT)  DBGVIEW(*SOURCE) " > ./src/build/$*-clle.txt 2>&1
	@echo "$* (X)"

# Link target for service programs
link:
	-system -v "CRTSRVPGM SRVPGM($(LIB)/COMLOG) MODULE($(LIB)/COMLOG) SRCSTMF('./src/comLog.BND') TGTRLS(*CURRENT)" 
	-system -v "CRTPGM PGM($(LIB)/EXLOG) MODULE(EXLOG) ENTMOD(EXLOG) ACTGRP(QILE) BNDSRVPGM($(LIB)/COMLOG) TGTRLS(*CURRENT)"  

prep:
	@test -d ./src/build || mkdir ./src/build