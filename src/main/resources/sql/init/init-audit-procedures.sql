CREATE OR REPLACE FUNCTION update_notification() RETURNS TRIGGER
    language plpgsql
as
$$
DECLARE
    rec RECORD;
    dat RECORD;
    payload TEXT;
BEGIN
    payload := json_build_object(
            'timestamp', CURRENT_TIMESTAMP,
            'action', TG_OP,
            'identity', TG_TABLE_NAME,
            'record', to_jsonb(json_strip_nulls(row_to_json(NEW))),
            'old', to_jsonb(json_strip_nulls(row_to_json(OLD)))
    )::text;

    IF EXISTS( SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = current_schema() AND tg_table_name = 'AuditTrail' )
    THEN
        INSERT INTO "AuditTrail"
        ( timestamp, "Action", "Table", "Record", "PreviousRecord" )
        VALUES
        ( CURRENT_TIMESTAMP, TG_OP, TG_TABLE_NAME, to_jsonb(json_strip_nulls(row_to_json(NEW))), to_jsonb(json_strip_nulls(row_to_json(OLD))));
    END IF;

    PERFORM pg_notify( 'change_db_event', payload );
    RETURN NEW;
END
$$;

CREATE OR REPLACE FUNCTION setup_trigger( table_name TEXT ) RETURNS VOID
AS
$$
BEGIN
    EXECUTE remove_trigger( table_name );
    EXECUTE FORMAT( 'CREATE TRIGGER %s_audit_trigger AFTER INSERT OR UPDATE OR DELETE ON "%s" FOR EACH ROW EXECUTE PROCEDURE update_notification();', table_name, table_name);
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION remove_trigger( table_name TEXT ) RETURNS VOID
AS
$$
BEGIN
    EXECUTE FORMAT( 'DROP TRIGGER IF EXISTS %s_audit_trigger ON "%s";', table_name, table_name);
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION audit_control_update() RETURNS TRIGGER
    language plpgsql
as
$$
BEGIN
    CASE TG_OP
        WHEN 'INSERT' THEN
            EXECUTE setup_trigger( NEW."AuditTable"::text );
        WHEN 'DELETE' THEN
            EXECUTE remove_trigger( OLD."AuditTable"::text );
    END CASE;
    RETURN NEW;
END
$$;

DROP TRIGGER IF EXISTS audit_control_change ON "AuditControl";
CREATE TRIGGER audit_control_change
    AFTER INSERT OR DELETE
    ON "AuditControl"
    FOR EACH ROW
EXECUTE PROCEDURE audit_control_update();