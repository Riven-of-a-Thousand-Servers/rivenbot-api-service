CREATE TABLE IF NOT EXISTS pgcr (
    instance_id bigint PRIMARY KEY,
    blob bytea NOT NULL
);

CREATE TABLE IF NOT EXISTS activity_name (
    id bigint PRIMARY KEY,
    label text NOT NULL,
    is_active boolean NOT NULL,
    release_date timestamp(0) with time zone NOT NULL
);

CREATE TABLE IF NOT EXISTS activity_difficulty (
    id bigint PRIMARY KEY,
    label text NOT NULL
);

CREATE TABLE IF NOT EXISTS activity (
    hash bigint PRIMARY KEY,
    label text NOT NULL,
    name_id bigint NOT NULL,
    difficulty_id bigint NOT NULL,
    is_worlds_first boolean,
    CONSTRAINT activity_name_fk FOREIGN KEY (name_id) REFERENCES activity_name (id),
    CONSTRAINT activity_difficulty_fk FOREIGN KEY (difficulty_id) REFERENCES activity_difficulty (id)
);

CREATE TABLE IF NOT EXISTS instance (
    id bigint PRIMARY KEY,
    activity_hash bigint NOT NULL,
    is_fresh boolean NOT NULL,
    flawless boolean NOT NULL,
    completed boolean NOT NULL,
    player_count int NOT NULL,
    duration int NOT NULL,
    end_time timestamp NOT NULL,
    start_Time timestamp NOT NULL,
    CONSTRAINT instance_hash_fk FOREIGN KEY (activity_hash) REFERENCES activity (hash)
);

CREATE UNIQUE INDEX instance_activity_id_idx ON instance (id);

CREATE TABLE IF NOT EXISTS destiny_player (
    membership_id bigint PRIMARY KEY,
    membership_type int NOT NULL,
    icon_path text,
    display_name text,
    global_display_name text,
    global_display_name_code int,
    total_clears int NOT NULL DEFAULT 0,
    total_full_clears int NOT NULL DEFAULT 0,
    is_private boolean DEFAULT FALSE,
    last_crawled timestamp NOT NULL,
    last_seen timestamp
);

CREATE UNIQUE INDEX destiny_player_display_name ON destiny_player (display_name);

CREATE TABLE IF NOT EXISTS instance_player (
    instance_id bigint NOT NULL,
    membership_id bigint NOT NULL,
    completed boolean DEFAULT FALSE,
    time_played_seconds int NOT NULL,
    CONSTRAINT instance_player_pk PRIMARY KEY (instance_id, membership_id)
);

CREATE TABLE IF NOT EXISTS instance_character (
    instance_id bigint NOT NULL UNIQUE,
    membership_id bigint NOT NULL UNIQUE,
    character_id bigint NOT NULL UNIQUE,
    class_hash text NOT NULL,
    emblem_hash text NOT NULL,
    completed boolean NOT NULL,
    kills int NOT NULL,
    deaths int NOT NULL,
    assists int NOT NULL,
    kda DECIMAL NOT NULL,
    kdr DECIMAL NOT NULL,
    super_kills int NOT NULL,
    melee_kills int NOT NULL,
    grenade_kills int NOT NULL,
    efficiency int NOT NULL,
    time_played_seconds int NOT NULL,
    CONSTRAINT instance_character_pk PRIMARY KEY (instance_id, membership_id, character_id),
    CONSTRAINT instance_character_instance_fk FOREIGN KEY (instance_id) REFERENCES instance (id),
    CONSTRAINT instance_character_destiny_player_fk FOREIGN KEY (membership_id) REFERENCES destiny_player (membership_id)
);

CREATE TABLE IF NOT EXISTS weapon (
    hash BIGINT PRIMARY KEY,
    icon_url text NOT NULL,
    name text NOT NULL,
    equipment_slot text NOT NULL,
    damage_type text NOT NULL
);

CREATE TABLE IF NOT EXISTS instance_character_weapon (
    instance_id bigint NOT NULL,
    player_membership_id bigint NOT NULL,
    player_character_id bigint NOT NULL,
    weapon_id bigint NOT NULL,
    kills int NOT NULL DEFAULT 0,
    precision_kills int NOT NULL DEFAULT 0,
    precision_ratio DECIMAL NOT NULL DEFAULT 0.0,
    CONSTRAINT instance_character_weapon_pk PRIMARY KEY (instance_id, player_membership_id, player_character_id, weapon_id),
    CONSTRAINT instance_character_weapon_instance_fk FOREIGN KEY (instance_id) REFERENCES instance (id),
    CONSTRAINT instance_character_weapon_player_fk FOREIGN KEY (player_membership_id) REFERENCES destiny_player (membership_id),
    CONSTRAINT instance_character_weapon_character_fk FOREIGN KEY (player_character_id) REFERENCES instance_character (character_id),
    CONSTRAINT instance_character_weapon_weapon_fk FOREIGN KEY (weapon_id) REFERENCES weapon (hash)
);

