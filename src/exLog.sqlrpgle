**FREE

//////////////////////////////////////////////////
// CommonLogger.RPGLE
//
// This copybook contains the procedure prototypes for the
// Common Logger library. It is intended for use in
// applications that need to log messages to a common log file.
//
// Author: Damian Pietron
// Date: 2026-01-05
//////////////////////////////////////////////////

ctl-opt CCSID(*CHAR:*JOBRUN);
ctl-opt DatFmt(*ISO) TIMFMT(*ISO);
ctl-opt main(main) decedit('0.');
ctl-opt Option(*SRCSTMT:*SHOWCPY:*NODEBUGIO:*NOUNREF);

/If Defined(*CRTBNDRPG)
ctl-opt DftActGrp(*NO) ActGrp(*NEW);
/EndIf

/copy ../include/comLog

dcl-proc main;

    dcl-s rc int(10);

    rc = LoggerSetConfig('A510844' : 'COMLOG' : 50 : 1000000);
    if rc <> 0;
        return;
    endif;

    rc = LogInfo('This is an info message.');
    rc = LogWarn('This is a warning message.');
    rc = LogError('This is an error message.');
    rc = LogDebug('This is a debug message.');
    rc = LogFatal('This is a fatal message.');

    return;
end-proc;
