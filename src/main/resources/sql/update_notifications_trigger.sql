CREATE OR REPLACE function update_notification() returns trigger
    language plpgsql
as
$$
DECLARE
    rec RECORD;
    dat RECORD;
    payload TEXT;
BEGIN
    CASE TG_OP
        WHEN 'UPDATE' THEN
            rec := NEW;
            dat := OLD;
        WHEN 'INSERT' THEN
            rec := NEW;
        WHEN 'DELETE' THEN
            rec := OLD;
        ELSE
            RAISE EXCEPTION 'Unknown TG_OP: "%". Should not happen!', TG_OP;
        END CASE;

    payload := json_build_object(
            'timestamp', CURRENT_TIMESTAMP,
            'action', TG_OP,
            'identity', TG_TABLE_NAME,
            'record', to_jsonb(json_strip_nulls(row_to_json(rec))),
            'old', to_jsonb(json_strip_nulls(row_to_json(dat)))
        );

    INSERT INTO "Audit"
    ( timestamp, action, "TargetTable", record, old )
    VALUES( CURRENT_TIMESTAMP, TG_OP, TG_TABLE_NAME, to_jsonb(json_strip_nulls(row_to_json(rec))), to_jsonb(json_strip_nulls(row_to_json(dat))));

    PERFORM pg_notify( 'change_db_event', payload );
    RETURN rec;
END
$$;
