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
/if defined(COMMON_LOG_PR_INCLUDED)
/eof
/else
/define COMMON_LOG_PR_INCLUDED
/endif

/TITLE 'CommonLogger.RPGLE - Procedure Prototypes for Common Logger Library'

dcl-pr LoggerSetConfig int(10);
  logFileLib char(10) const;
  logFileName char(10) const;
  logSeverity int(10) value;
  logMaxSize int(10) value;
end-pr;

dcl-pr LogError int(10);
    message varchar(2048) const;
end-pr;

dcl-pr LogWarn int(10);
    message varchar(2048) const;
end-pr;

dcl-pr LogInfo int(10);
    message varchar(2048) const;
end-pr;

dcl-pr LogDebug int(10);
    message varchar(2048) const;
end-pr;

dcl-pr LogFatal int(10);
    message varchar(2048) const;
end-pr;

dcl-pr LogLongMessage int(10);
    severity int(10) value;
    message pointer value;
    messageLen int(10) value;
    offset int(10) value;
    additionals varchar(9999) options(*nopass); 
end-pr;

/TITLE 'CommonLogger.RPGLE - Constants for Log Severity Levels'

dcl-c LOG_DEBUG 10;
dcl-c LOG_INFO  20;
dcl-c LOG_WARN  30;
dcl-c LOG_ERROR 40;
dcl-c LOG_FATAL 50;
