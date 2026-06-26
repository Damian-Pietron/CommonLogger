# CommonLogger

A lightweight, configurable logging service program for **IBM i (AS/400)** written in **SQLRPGLE**. CommonLogger provides a simple API to log messages of varying severity levels into a dynamically created SQL table.

---

## Features

- **Multiple Log Severity Levels** — DEBUG, INFO, WARN, ERROR, and FATAL
- **Automatic Storage Provisioning** — Log table is created automatically if it doesn't exist
- **Severity Filtering** — Only messages at or above the configured severity are persisted
- **Large Message Support** — Log messages up to **1 MB** via CLOB storage
- **Caller Metadata Capture** — Automatically records user, job, program, procedure, and module from the call stack
- **Additional Context** — Optional `additionals` parameter for supplementary data (up to 9999 chars)
- **Service Program Architecture** — Bind once, use from any program via `BNDSRVPGM`
- **Configurable Max Message Size** — Truncate oversized messages to a defined limit

---

## Project Structure

```
CommonLogger/
├── include/
│   ├── comLog.rpgle        # Public prototypes and constants
│   └── Internal.rpgle      # Internal PSDS and helper definitions
├── src/
│   ├── comLog.sqlrpgle     # Core logging service program source
│   ├── comLog.BND          # Binder source (exported symbols)
│   └── exLog.sqlrpgle      # Example usage program
├── test/
│   └── comLog.test.sqlrpgle # Unit tests
├── makefile                 # Build automation
└── README.md
```

---

## Log Severity Levels

| Constant     | Value | Description                        |
|-------------|-------|------------------------------------|
| `LOG_DEBUG`  | 10    | Detailed diagnostic information    |
| `LOG_INFO`   | 20    | General informational messages     |
| `LOG_WARN`   | 30    | Warning conditions                 |
| `LOG_ERROR`  | 40    | Error conditions                   |
| `LOG_FATAL`  | 50    | Critical failures                  |

Only messages with a severity **equal to or above** the configured level are written. For example, configuring severity as `LOG_WARN` (30) will log WARN, ERROR, and FATAL messages, but skip DEBUG and INFO.

> **Note:** `LOG_FATAL` messages are **always** logged regardless of the configured severity.

---

## API Reference

### `LoggerSetConfig`

Initializes the logger configuration. **Must be called before any logging.**

```rpgle
dcl-pr LoggerSetConfig int(10);
    logFileLib    char(10) const;   // Library for the log table
    logFileName   char(10) const;   // Log table name
    logSeverity   int(10) value;    // Minimum severity to log (10–50)
    logMaxSize    int(10) value;    // Max message size (0 = unlimited)
end-pr;
```

**Returns:** `0` on success, `1` on validation error.

---

### `LogDebug` / `LogInfo` / `LogWarn` / `LogError` / `LogFatal`

Convenience procedures for logging at a specific severity level.

```rpgle
dcl-pr LogDebug int(10);
    message varchar(2048) const;
end-pr;

dcl-pr LogInfo int(10);
    message varchar(2048) const;
end-pr;

dcl-pr LogWarn int(10);
    message varchar(2048) const;
end-pr;

dcl-pr LogError int(10);
    message varchar(2048) const;
end-pr;

dcl-pr LogFatal int(10);
    message varchar(2048) const;
end-pr;
```

**Returns:** `0` on success, `1` on error.

---

### `LogLongMessage`

Logs a message from a pointer with explicit length control. Supports messages up to **1 MB**.

```rpgle
dcl-pr LogLongMessage int(10);
    severity     int(10) value;            // Log severity level
    message      pointer value;            // Pointer to message data
    messageLen   int(10) value;            // Length of the message
    offset       int(10) value;            // Byte offset into the message
    additionals  varchar(9999) options(*nopass); // Optional extra context
end-pr;
```

**Returns:** `0` on success, `1` on error.

---

## Log Table Schema

The log table is created automatically on first use with the following schema:

| Column         | Type                  | Description                          |
|---------------|-----------------------|--------------------------------------|
| `LogID`        | `BIGINT IDENTITY`     | Auto-generated primary key           |
| `LogSeverity`  | `INT`                 | Numeric severity level               |
| `LogBody`      | `CLOB(1M)`            | The log message content              |
| `LogDate`      | `TIMESTAMP`           | Defaults to `CURRENT_TIMESTAMP`      |
| `LogUser`      | `CHAR(10)`            | Job user who generated the log       |
| `LogJob`       | `CHAR(10)`            | Job name                             |
| `LogProgram`   | `CHAR(10)`            | Calling program name                 |
| `LogProcedure` | `CHAR(10)`            | Calling procedure name               |
| `Module`       | `CHAR(10)`            | Calling module name                  |
| `Additionals`  | `VARCHAR(9999)`       | Optional supplementary information   |

---

## Usage Example

```rpgle
**FREE
ctl-opt main(main);

/copy ../include/comLog

dcl-proc main;
    dcl-s rc int(10);

    // 1. Configure the logger
    rc = LoggerSetConfig('MYLIB' : 'APPLOG' : 20 : 1000000);
    if rc <> 0;
        return;
    endif;

    // 2. Log messages at various severity levels
    rc = LogInfo('Application started successfully.');
    rc = LogWarn('Configuration file not found, using defaults.');
    rc = LogError('Failed to connect to remote service.');
    rc = LogDebug('Variable X = 42');
    rc = LogFatal('Unrecoverable error — shutting down.');

    return;
end-proc;
```

A complete working example is provided in [`src/exLog.sqlrpgle`](src/exLog.sqlrpgle).

---

## Building

The project uses a [`makefile`](makefile) for compilation on IBM i via QShell.

### Prerequisites

- IBM i with ILE RPG and SQL support
- QShell (`/usr/bin/qsh`)

### Build Commands

```sh
# Build with default library
make LIB=MYLIB

# Build all targets (modules + service program + example program)
make all LIB=MYLIB
```

### Build Steps

1. **`prep`** — Creates the `src/build/` output directory
2. **Module Compilation** — Compiles `comLog.sqlrpgle` and `exLog.sqlrpgle` into `*MODULE` objects using `CRTSQLRPGI`
3. **Link** — Creates the `COMLOG` service program (`*SRVPGM`) and binds the example program `EXLOG` to it

### Binding to Your Program

To use CommonLogger in your own program, bind to the service program:

```cl
CRTPGM PGM(MYLIB/MYPGM) MODULE(MYPGM) BNDSRVPGM(MYLIB/COMLOG)
```

Include the prototypes in your source:

```rpgle
/copy ../include/comLog
```

---

## Exported Symbols

Defined in [`src/comLog.BND`](src/comLog.BND) with signature `COMMONLOGGER_V1.0`:

| Symbol              | Procedure          |
|--------------------|--------------------|
| `LOGGERSETCONFIG`   | `LoggerSetConfig`  |
| `LOGERROR`          | `LogError`         |
| `LOGWARN`           | `LogWarn`          |
| `LOGINFO`           | `LogInfo`          |
| `LOGDEBUG`          | `LogDebug`         |
| `LOGFATAL`          | `LogFatal`         |
| `LOGLONGMESSAGE`    | `LogLongMessage`   |

---

## Error Handling

All procedures return an integer status code:

| Code | Meaning |
|------|---------|
| `0`  | Success |
| `1`  | Error (validation failure, SQL error, or missing configuration) |

When an error occurs, an informational message (`CPF9898`) is sent to the job log with a descriptive message and a 4-character error key:

| Key    | Description                                |
|--------|--------------------------------------------|
| `LGLN` | Log file library is required / invalid length |
| `LGFN` | Log file name is required                  |
| `LGSV` | Invalid log severity value                 |
| `LGMS` | Invalid log max size                       |
| `LGNC` | Logger not configured                      |
| `LGOF` | Invalid offset value                       |
| `LGST` | Failed to ensure log storage               |
| `SQLV` | SQL state validation error                 |

---

## License

Open source. See repository for license details.

---

## Author

**Damian Pietron** — 2026