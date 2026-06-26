**FREE
//////////////////////////////////////////////////
// INTERNAL.RPGLE
// 
// This copybook contains internal procedures and
// definitions for the Common Logger library. 
// It is intended for internal use only.
//
// Author: Damian Pietron
// Date: 2026-01-05
//////////////////////////////////////////////////
/if defined(INTERNAL_INCLUDED)
/eof
/else
/define INTERNAL_INCLUDED
/endif

// +--------------------------------------+
// | PROGRAM STATUS DATA STRUCTURE (PSDS) |
// +--------------------------------------+
dcl-ds psds PSDS qualified;
    program char(10) pos(1);
    procedureName *PROC;
    statusCode *STATUS;
    prvStatus zoned(5) pos(16);
    srcListLineNum char(8) pos(21);
    routineName *ROUTINE;
    nbrPassedParms *PARMS;
    exceptionType char(3) pos(40);
    exceptionNumber char(4) pos(43);
    pgmLib char(10) pos(81);
    ExceptionData char(80) pos(91);
    messageText char(80) pos(91);
    ExceptionId char(4) pos(171);
    date char(8) pos(191);
    year zoned(2) pos(199);
    lastFileUsed char(8) pos(201);
    fileErrorInfo char(35) pos(209);
    rpgFileRoutine char(6) pos(214);
    rpgStatement char(6) pos(214);
    fileRecordFormat char(8) pos(236);
    jobUserNumber char(26) pos(244);
    job char(10) pos(244);
    jobName char(10) pos(244);
    User char(10) pos(254);
    jobUser char(10) pos(254);
    number zoned(6) pos(264);
    jobnumber zoned(6) pos(264);
    jobnumberalpha char(6) pos(264);
    jobDate zoned(6) pos(270);
    runDate zoned(6) pos(276);
    runTime zoned(6) pos(282);
    runtimeHour char(2) pos(282);
    runtimeMinute char(2) pos(284);
    runtimeSecond char(2) pos(286);
    createDate char(6) pos(288);
    createTime char(6) pos(294);
    compilerLevel char(4) pos(300);
    srcFile char(10) pos(304);
    srcLib char(10) pos(314);
    srcMbr char(10) pos(324);
    currentPgmProc char(10) pos(334);
    currentModule char(10) pos(344);
    currentUser char(10) pos(358);
end-ds;
