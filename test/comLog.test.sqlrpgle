**free

ctl-opt nomain ccsidcvt(*excp) ccsid(*char : *jobrun);
ctl-opt bnddir('COMLOG');

/include qinclude,TESTCASE
/include ../include/comLog

dcl-proc test_LoggerSetConfig export;
  dcl-pi *n extproc(*dclcase) end-pi;

  dcl-s logFileLib char(10);
  dcl-s logFileName char(10);
  dcl-s logSeverity int(10);
  dcl-s logMaxSize int(10);
  dcl-s actual int(10);
  dcl-s expected int(10);

  logFileLib = 'COMLOG';
  logFileName = 'COMLOG';
  logSeverity = 50;
  logMaxSize = 1000000;

  actual = LoggerSetConfig(logFileLib : logFileName : logSeverity : logMaxSize);

  expected = 0;

  iEqual(expected : actual : 'actual');
end-proc;

dcl-proc test_LogError export;
  dcl-pi *n extproc(*dclcase) end-pi;

  dcl-s message varchar(2048);
  dcl-s actual int(10);
  dcl-s expected int(10);

  mock_Set_config();

  message = 'dummy error message';

  actual = LogError(message);

  expected = 0;

  iEqual(expected : actual : 'actual');
end-proc;

dcl-proc test_LogWarn export;
  dcl-pi *n extproc(*dclcase) end-pi;

  dcl-s message varchar(2048);
  dcl-s actual int(10);
  dcl-s expected int(10);

  mock_Set_config();

  message = 'dummy warning message';

  actual = LogWarn(message);

  expected = 0;

  iEqual(expected : actual : 'actual');
end-proc;

dcl-proc test_LogInfo export;
  dcl-pi *n extproc(*dclcase) end-pi;

  dcl-s message varchar(2048);
  dcl-s actual int(10);
  dcl-s expected int(10);

  mock_Set_config();

  message = 'dummy error message';

  actual = LogInfo(message);

  expected = 0;

  iEqual(expected : actual : 'actual');
end-proc;

dcl-proc test_LogDebug export;
  dcl-pi *n extproc(*dclcase) end-pi;

  dcl-s message varchar(2048);
  dcl-s actual int(10);
  dcl-s expected int(10);

  mock_Set_config();

  message = 'dummy error message';

  actual = LogDebug(message);

  expected = 0;

  iEqual(expected : actual : 'actual');
end-proc;

dcl-proc test_LogFatal export;
  dcl-pi *n extproc(*dclcase) end-pi;

  dcl-s message varchar(2048);
  dcl-s actual int(10);
  dcl-s expected int(10);

  mock_Set_config();

  message = 'dummy fatal message';

  actual = LogFatal(message);

  expected = 0;

  iEqual(expected : actual : 'actual');
end-proc;

dcl-proc test_LogLongMessage export;
  dcl-pi *n extproc(*dclcase) end-pi;

  dcl-s severity int(10);
  dcl-s message pointer;
  dcl-s messageLen int(10);
  dcl-s offset int(10);
  dcl-s additionals varchar(9999);
  dcl-s actual int(10);
  dcl-s expected int(10);

  dcl-s longMessage varchar(2048);

  mock_Set_config();
  longMessage = 'This is a long message that exceeds the maximum length of 2048 characters. ' +
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. ' +
                'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ' +
                'Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. ' +
                'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. ';

  severity = 50;
  message = %addr(longMessage);
  messageLen = %len(longMessage);
  offset = 0;
  additionals = 'dummy additional information';

  actual = LogLongMessage(severity : message : messageLen : offset : additionals);

  expected = 0;

  iEqual(expected : actual : 'actual');
end-proc;

dcl-proc mock_Set_config export;
  dcl-pi *n extproc(*dclcase) end-pi;

  dcl-s logFileLib char(10);
  dcl-s logFileName char(10);
  dcl-s logSeverity int(10);
  dcl-s logMaxSize int(10);

  logFileLib = 'COMLOG';
  logFileName = 'COMLOG';
  logSeverity = 50;
  logMaxSize = 1000000;

  LoggerSetConfig('COMLOG' : 'COMLOG' : LOG_DEBUG : 1000000);


end-proc;