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
ctl-opt nomain decedit('0.');
ctl-opt Option(*SRCSTMT:*SHOWCPY:*NODEBUGIO:*NOUNREF);

/If Defined(*CRTBNDRPG)
ctl-opt DftActGrp(*NO) ActGrp(*NEW);
/EndIf

/copy ../include/comLog
/copy ../include/INTERNAL

dcl-pr memcpy pointer extproc('memcpy');
    Dest pointer value;
    Src  pointer value;
    Len  uns(10) value;
end-pr;

Dcl-pr  SendEscMsg extpgm('QMHSNDPM');
    MsgID          Char(7)    CONST;
    MsgFile        Char(20)   CONST;
    MsgDta         Char(80)   CONST;
    MsgDtaLen      Int(10)    CONST;
    MsgType        Char(10)   CONST;
    MsgQ           Char(10)   CONST;
    MsgQNbr        Int(10)    CONST;
    MsgKey         Char(4);
    ErrorDS        Char(16);
End-Pr;

dcl-ds GlobalLoggerConfigDs qualified;
    logFileLib char(10);
    logFileName char(10);
    logSeverity int(10);
    logMaxSize int(10);
end-ds;

dcl-s isConfigured ind inz(*off);
dcl-s isStorageEnsured ind inz(*off);

dcl-proc LoggerSetConfig export;
    dcl-pi *n int(10);
        logFileLib char(10) const;
        logFileName char(10) const;
        logSeverity int(10) value;
        logMaxSize int(10) value;
    end-pi;

    // Validate input parameters
    if logFileLib = '';
        ExceptionHandler('Log file lib is required': 'LGLN');
        return 1;
    elseif logFileName = '';
        ExceptionHandler('Log file name is required': 'LGFN');
        return 1;
    endif;

    if logSeverity < LOG_DEBUG or logSeverity > LOG_FATAL;
        ExceptionHandler('Log severity must be between LOG_FATAL and LOG_DEBUG': 'LGSV');
        return 1;
    endif;

    if logMaxSize < 0;
        ExceptionHandler('Log max size must be non-negative': 'LGMS');
        return 1;
    endif;

    GlobalLoggerConfigDs.logFileLib = logFileLib;
    GlobalLoggerConfigDs.logFileName = logFileName;
    GlobalLoggerConfigDs.logSeverity = logSeverity;
    GlobalLoggerConfigDs.logMaxSize = logMaxSize;

    isConfigured = *on;

    return 0;
end-proc;

dcl-proc LogError export;
    dcl-pi *n int(10);
        message varchar(2048) const;
    end-pi;

    dcl-s locMessage varchar(2048);

    if GlobalLoggerConfigDs.logSeverity < LOG_ERROR;
        return 0; // Skip logging if severity is lower than configured
    endif;

    locMessage = message;
    return LogLongMessage(LOG_ERROR: %addr(locMessage): %len(locMessage): 2);
end-proc; 

dcl-proc LogWarn export;
    dcl-pi *n int(10);
        message varchar(2048) const;
    end-pi;

    dcl-s locMessage varchar(2048);

    if GlobalLoggerConfigDs.logSeverity < LOG_WARN;
        return 0; // Skip logging if severity is lower than configured
    endif;

    locMessage = message;
    return LogLongMessage(LOG_WARN: %addr(locMessage): %len(locMessage): 2);
end-proc; 

dcl-proc LogInfo export;
    dcl-pi *n int(10);
        message varchar(2048) const;
    end-pi;

    dcl-s locMessage varchar(2048);

    if GlobalLoggerConfigDs.logSeverity < LOG_INFO;
        return 0; // Skip logging if severity is lower than configured
    endif;

    locMessage = message;
    return LogLongMessage(LOG_INFO: %addr(locMessage): %len(locMessage): 2);
end-proc;

dcl-proc LogDebug export;
    dcl-pi *n int(10);
        message varchar(2048) const;
    end-pi;

    dcl-s locMessage varchar(2048);

    if GlobalLoggerConfigDs.logSeverity < LOG_DEBUG;
        return 0; // Skip logging if severity is lower than configured
    endif;

    locMessage = message;
    return LogLongMessage(LOG_DEBUG: %addr(locMessage): %len(locMessage): 2);
end-proc;

dcl-proc LogFatal export;
    dcl-pi *n int(10);
        message varchar(2048) const;
    end-pi;

    dcl-s locMessage varchar(2048);

    locMessage = message;
    return LogLongMessage(LOG_FATAL: %addr(locMessage): %len(locMessage): 2);
end-proc; 

dcl-proc LogLongMessage export;
    dcl-pi *n int(10);
        severity int(10) value;
        message pointer value;
        messageLen int(10) value;
        offset int(10) value;
        additionals varchar(9999) options(*nopass);
    end-pi;

    dcl-s logFileLib char(10);
    dcl-s logFileName char(10);
    dcl-s logMaxSize int(10);
    dcl-s MessageClob sqltype(clob:1000000);
    dcl-s sqlStmt varchar(1000);
    dcl-s AdditionalsLocal varchar(9999) inz('');
    dcl-s rc int(10);
    dcl-s User char(10) inz(*blanks);
    dcl-s Job char(10) inz(*blanks);
    dcl-s Program char(10) inz(*blanks);
    dcl-s Procedure char(10) inz(*blanks);
    dcl-s Module char(10) inz(*blanks);

    // Fetch configuration
    logFileLib = GlobalLoggerConfigDs.logFileLib;
    logFileName = GlobalLoggerConfigDs.logFileName;
    logMaxSize = GlobalLoggerConfigDs.logMaxSize;

    // Validate parameters
    if %parms() >= 5;
        AdditionalsLocal = additionals;
    endif;

    if not isConfigured;
        ExceptionHandler('Logger is not configured. Call LoggerSetConfig first.': 'LGNC');
        return 1;
    endif;

    if severity < LOG_DEBUG or severity > LOG_FATAL;
        ExceptionHandler('Log severity must be between LOG_FATAL and LOG_DEBUG': 'LGSV');
        return 1;
    endif;

    if offset < 0;
        ExceptionHandler('Offset must be non-negative': 'LGOF');
        return 1;
    endif;

    if messageLen < 0;
        ExceptionHandler('Message length must be non-negative': 'LGLN');
        return 1;
    endif;

    if messageLen > logMaxSize and logMaxSize > 0;
        messageLen = logMaxSize; // Truncate if body exceeds max size
    endif;
    
        // Ensure storage is available for the log file    
    if not isStorageEnsured;
        rc = LoggerEnsureStorage(logFileLib: logFileName);
        if rc <> 0;
            ExceptionHandler('Failed to ensure log storage.': 'LGST');
            return 1;
        endif;
    endif;    

    if messageLen > 1000000;
        messageLen = 1000000;
    endif;

    MessageClob_Len = messageLen;
    memcpy(%addr(MessageClob_Data): message + offset: messageLen);

    // Retrieve user and job from PSDS (these are job-level, always correct)
    User = psds.jobUser;
    Job = psds.jobName;
    
    // Retrieve caller's program, procedure, and module from the call stack
    FetchCallerInfo(Program:Procedure:Module);
        
    // Set SQL options for the session
    EXEC SQL SET OPTION COMMIT = *NONE;

    sqlStmt = 'INSERT INTO '+%trim(logFileLib)+'.'+%trim(logFileName)+
                  ' (LogSeverity, LogBody, LogUser, LogJob, LogProgram, LogProcedure, Module, Additionals) ' +
                  ' VALUES (?, ?, ?, ?, ?, ?, ?, ?)';
    exec sql
            PREPARE stmt FROM :sqlStmt;
        
    exec sql
            EXECUTE stmt USING :severity, :MessageClob, :User, :Job, :Program, :Procedure, :Module, :AdditionalsLocal;
        
    rc = SqlStateValidator(SQLSTATE: 'during logging - data insertion');

    return rc;
end-proc;   

dcl-proc LoggerEnsureStorage;
    dcl-pi *n int(10);
    logFileLib char(10) const;
    logFileName char(10) const;
end-pi;

dcl-s fileExists int(10);
dcl-s sqlStmt varchar(1000);
dcl-s rc int(10);
dcl-s locFileLib char(10);
dcl-s locFileName char(10);

locFileLib = logFileLib;
locFileName = logFileName;

exec sql
        SELECT COUNT(*) INTO :fileExists
        FROM QSYS2.SYSTABLES
        WHERE TABLE_NAME = UPPER(:locFileName)
        AND TABLE_SCHEMA = :locFileLib;
    
if fileExists = 0;
    sqlStmt = 'CREATE TABLE '+%trim(logFileLib)+
                   '.'+%trim(logFileName)+' ( ' +
                  'LogID BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,' +
                  'LogSeverity INT,' +
                  'LogBody CLOB(1M),' +
                  'LogDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,' +
                  'LogUser CHAR(10),' +
                  'LogJob CHAR(10),' +
                  'LogProgram CHAR(10),' +
                  'LogProcedure CHAR(10),' +
                  'Module CHAR(10),' +
                  'Additionals VARCHAR(9999)' +
                  ')';
    exec sql EXECUTE IMMEDIATE :sqlStmt;
    // SQLSTATE 42710 = object already exists
    // SQLSTATE 55019 = object in use / already exists (common with QTEMP)
    if SQLSTATE <> '00000' and SQLSTATE <> '42710' and SQLSTATE <> '55019';
        rc = SqlStateValidator(SQLSTATE: 'during logging - table creation');
    endif;
endif; 

if rc = 0;
    isStorageEnsured = *on;
endif;

return rc;
end-proc;


dcl-proc SqlStateValidator;
    //////////////////////////////////////////////////////////
    // Procedure to validate SQLSTATE after SQL operations
    // Parameters:
    //   - sqlStateC: SQLSTATE code
    //   - additionalInfo: Additional context information
    //////////////////////////////////////////////////////////
dcl-pi *n int(10);
    sqlStateC char(5) value;
    additionalInfo varchar(50) value;
end-pi;

if sqlStateC <> '00000';
    ExceptionHandler('SQL Error: ' + additionalInfo + ' - SQLSTATE - ' + sqlStateC: 'SQLV');
    return 1;
endif;
return 0;
end-proc;


//-----------------------------------------------------------------------
// Procedure to handle exceptions and send escape messages
// Parameters:
//   - MsgDta: Message data
//   - MsgKey: Message key
//-----------------------------------------------------------------------

dcl-proc ExceptionHandler export;
dcl-pi *n;
    MsgDta Char(80) value;
    MsgKey Char(4) value;
end-pi;

Dcl-DS ErrorDS Len(16);
    BytesProv      Int(10)    INZ(16);
    BytesAvail     Int(10);
    ExceptionID    Char(7);
end-DS;

SendEscMsg ('CPF9898':
    'QCPFMSG   QSYS':
    MsgDta: %len(MsgDta):
    '*INFO': '*': 2: MsgKey: ErrorDS);
return;
end-proc;

dcl-proc FetchCallerInfo export;
    dcl-pi *n int(10);
        Program char(10);
        Procedure char(10);
        Module char(10);
    end-pi;

    exec sql
        SELECT y.PROGRAM_NAME,                             
       y.MODULE_NAME,                              
       y.PROCEDURE_NAME  
       INTO :Program, :Module, :Procedure                          
        FROM (                                             
            SELECT *                                       
            FROM TABLE(QSYS2.STACK_INFO('*')) AS S         
            WHERE PROGRAM_NAME = 'COMLOG'                  
            ORDER BY ORDINAL_POSITION ASC                  
            LIMIT 1                                        
        ) AS x,                                            
        LATERAL (                                          
            SELECT *                                       
            FROM TABLE(QSYS2.STACK_INFO('*')) AS S2        
            WHERE ORDINAL_POSITION = x.ORDINAL_POSITION - 1
        ) AS y;                                             

    return 0;
end-proc;