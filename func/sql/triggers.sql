
BEGIN
    -- If can_view is false or NULL, delete the row instead of updating
    IF NEW.can_view IS DISTINCT FROM TRUE THEN
        DELETE FROM level_permission WHERE id = OLD.id;
        RETURN NULL; -- stop the update
    END IF;

    RETURN NEW; -- allow update
END;

