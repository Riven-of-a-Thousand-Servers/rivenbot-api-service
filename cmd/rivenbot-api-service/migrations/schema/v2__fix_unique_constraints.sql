BEGIN;
ALTER TABLE instance_character
    DROP CONSTRAINT IF EXISTS instance_character_instance_id_key,
    DROP CONSTRAINT IF EXISTS instance_character_character_id_key,
    DROP CONSTRAINT IF EXISTS instance_character_membership_id_key;
ALTER TABLE instance_character_weapon
    DROP CONSTRAINT IF EXISTS instance_character_weapon_character_fk,
    DROP CONSTRAINT IF EXISTS instance_character_weapon_instance_fk,
    DROP CONSTRAINT IF EXISTS instance_character_weapon_player_fk;
ALTER TABLE instance_character_weapon
    ADD CONSTRAINT instance_character_weapon_character_fk FOREIGN KEY (instance_id, player_membership_id, player_character_id) REFERENCES instance_character (instance_id, membership_id, character_id);
COMMIT;

