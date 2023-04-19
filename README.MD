# PostgreSQL Table Audit

A simple toy implementation of Table change audit trail using PostgreSQL triggers.

The implementation sets up two tables:-
- AuditControl
- AuditTrail

## AuditControl
The AuditControl is a simple control table that contains the list of tables that are
currently being audited and when the audit started.

## AuditTrail
The AuditTrail contains change events on audited tables and provides information for
the table that was modified, what was the change, the old and new values and when.

## Usage

User would add/remove a target `table` into `AuditTable` column of the `AuditControl` table. 
Triggers have been setup on the `AuditControl` table such that `INSERT` or `DELETE` 
actions will automatically setup the audit triggers to the intended tables.

Audited tables have triggers configured to capture changes into the `AuditTrail` table and
will note:-
- `timestamp` the time of change
- `Table` the table the change occurred
- `Action` the action of the change `INSERT`, `UPDATE`, `DELETE`
- `Record` the CURRENT record
- `PreviousRecord` the PREVIOUS record

Records are stored as JSONB data type to facilitate easy querying for analysis.

## Installation

The installation script is in the `src/main/resources/init` folders and contains two
scripts:-
- `init-audit-tables.sql` : Creates the Tables necessary for the implementation
- `init-audit-triggers.sql` : Creates the triggers necessary for the implementation

## Note

Experimentally the implementation also uses the PostgreSQL `NOTIFY` and `LISTEN` to
broadcast the change events to listening connections, but will require a JDBC Driver
that supports Notifications.

Audit change events shall be published on the `change_db_event` channel.

One known JDBC Driver that implements asychronously receiving notifications from PostgreSQL
is the pgjdbc-ng driver.

    <dependency>
        <groupId>com.impossibl.postgres</groupId>
        <artifactId>pgjdbc-ng</artifactId>
        <version>0.8.9</version>
    </dependency>

A simple example implementation is implemented as the Unit Test `AuditListenerTest`.

## Future Improvements

`AuditControl` is currently a simple table used as a 'control' surface for users to trigger 
the addition or removal of audit triggers on target tables.

Future improvement could include enhancing the audit triggers to listen to ONLY specific changes
on the target table and the control for these specific changes could be part of the `AuditControl`
table row.

## References
- https://gist.github.com/goliatone/5fbeb1912e5937e8e3cf94618be9bebf
- https://wiki.postgresql.org/wiki/Audit_trigger_91plus
