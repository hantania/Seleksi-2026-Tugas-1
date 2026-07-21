DROP VIEW IF EXISTS view_total_score CASCADE;
DROP VIEW IF EXISTS view_idol_age CASCADE;
DROP TRIGGER IF EXISTS trg_group_status_changed ON groups CASCADE;
DROP FUNCTION IF EXISTS group_status_changed() CASCADE;
DROP TABLE IF EXISTS fans_vote_groups CASCADE;
DROP TABLE IF EXISTS fans_fandoms CASCADE;
DROP TABLE IF EXISTS fandom_colors CASCADE;
DROP TABLE IF EXISTS fandoms CASCADE;
DROP TABLE IF EXISTS tracks CASCADE;
DROP TABLE IF EXISTS albums CASCADE;
DROP TABLE IF EXISTS group_metrics CASCADE;
DROP TABLE IF EXISTS group_idols CASCADE;
DROP TABLE IF EXISTS hiatus_groups CASCADE;
DROP TABLE IF EXISTS disbanded_groups CASCADE;
DROP TABLE IF EXISTS active_groups CASCADE;
DROP TABLE IF EXISTS groups CASCADE;
DROP TABLE IF EXISTS labels CASCADE;
DROP TABLE IF EXISTS idols CASCADE;
DROP TABLE IF EXISTS votings CASCADE;
DROP TABLE IF EXISTS fans_users CASCADE;

CREATE TABLE fans_users (
    ID_user SERIAL,
    username VARCHAR(100) NOT NULL UNIQUE,
    level SMALLINT,
    register_date DATE,

    PRIMARY KEY(ID_user),
    CHECK(level BETWEEN 1 AND 5)
);

CREATE TABLE votings (
    ID_voting SERIAL,
    name VARCHAR(100) NOT NULL UNIQUE,
    start_date DATE,
    end_date DATE,

    PRIMARY KEY(ID_voting),
    CHECK(end_date > start_date)
);

CREATE TABLE labels (
    ID_label SERIAL,
    name VARCHAR(100) NOT NULL UNIQUE,
    founded_year INT,
    founder VARCHAR(100),

    PRIMARY KEY(ID_label)
);

CREATE TABLE idols (
    ID_idol SERIAL,
    stage_name VARCHAR(50) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    birthday DATE,
    birth_adm_area VARCHAR(100),
    birth_country VARCHAR(100),
    height NUMERIC(5,2),

    PRIMARY KEY(ID_idol)
);

CREATE TABLE groups (
    ID_group SERIAL,
    ID_label INT,
    name VARCHAR(100) NOT NULL,
    other_name VARCHAR(100),
    status VARCHAR(15),
    debut_date DATE,
    ID_parent_group INT,

    PRIMARY KEY(ID_group),
    CHECK(status IN ('ACTIVE','DISBANDED', 'HIATUS')),
    FOREIGN KEY(ID_label) REFERENCES labels(ID_label) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY(ID_parent_group) REFERENCES groups(ID_group) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE active_groups (
    ID_group INT,
    latest_comeback_date DATE,

    PRIMARY KEY(ID_group),
    FOREIGN KEY(ID_group) REFERENCES groups(ID_group) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE disbanded_groups (
    ID_group INT,
    disband_year INT,
    disband_reason VARCHAR(200),

    PRIMARY KEY(ID_group),
    FOREIGN KEY(ID_group) REFERENCES groups(ID_group) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE hiatus_groups(
    ID_group INT,
    hiatus_year INT,
    hiatus_reason VARCHAR(200),

    PRIMARY KEY(ID_group),
    FOREIGN KEY(ID_group) REFERENCES groups(ID_group) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE group_idols (
    ID_group INT NOT NULL,
    ID_idol INT NOT NULL,
    role VARCHAR(25) NOT NULL,

    PRIMARY KEY(ID_group, ID_idol, role),
    CHECK(role IN ('RAPPER', 'VOCALIST', 'LEADER', 'DANCER', 'VISUAL', 'OTHERS')),
    FOREIGN KEY(ID_group) REFERENCES groups(ID_group) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY(ID_idol) REFERENCES idols(ID_idol) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE group_metrics (
    ID_group INT NOT NULL,
    scraped_at TIMESTAMP NOT NULL,
    rank INT,
    total_bias_votes INT,
    dance_score NUMERIC(5,2),
    vocal_score NUMERIC(5,2),
    stage_score NUMERIC(5,2),
    artistry_score NUMERIC(5,2),
    visual_score NUMERIC(5,2),

    PRIMARY KEY(ID_group, scraped_at),
    FOREIGN KEY(ID_group) REFERENCES groups(ID_group) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE albums (
    ID_album SERIAL,
    ID_group INT NOT NULL,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(30),
    release_date DATE,
    language VARCHAR(30),
    description TEXT,

    PRIMARY KEY(ID_album),
    FOREIGN KEY(ID_group) REFERENCES groups(ID_group) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE tracks (
    ID_album INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    genre VARCHAR(50),

    PRIMARY KEY(ID_album, title),
    FOREIGN KEY(ID_album) REFERENCES albums(ID_album) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE fandoms (
    ID_fandom SERIAL,
    ID_group INT NOT NULL,
    name VARCHAR(100) NOT NULL,

    PRIMARY KEY(ID_fandom),
    FOREIGN KEY(ID_group) REFERENCES groups(ID_group) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE fandom_colors (
    ID_fandom INT NOT NULL,
    color_identity VARCHAR(30) NOT NULL,

    PRIMARY KEY (ID_fandom, color_identity),
    FOREIGN KEY (ID_fandom) REFERENCES fandoms(ID_fandom) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE fans_fandoms (
    ID_user INT NOT NULL,
    ID_fandom INT NOT NULL,

    PRIMARY KEY(ID_user, ID_fandom),
    FOREIGN KEY(ID_user) REFERENCES fans_users(ID_user) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY(ID_fandom) REFERENCES fandoms(ID_fandom) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE fans_vote_groups (
    ID_user INT NOT NULL,
    ID_group INT NOT NULL,
    ID_voting INT NOT NULL,
    vote_timestamp TIMESTAMP NOT NULL,

    PRIMARY KEY(ID_user, ID_group, ID_voting),
    FOREIGN KEY(ID_user) REFERENCES fans_users(ID_user) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY(ID_group) REFERENCES groups(ID_group) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY(ID_voting) REFERENCES votings(ID_voting) ON UPDATE CASCADE ON DELETE CASCADE
);

-- Penanganan inherit
CREATE OR REPLACE FUNCTION group_status_changed()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'ACTIVE' THEN
        INSERT INTO active_groups(ID_group) 
        VALUES (NEW.ID_group)
        ON CONFLICT (ID_group) DO NOTHING;
        DELETE FROM disbanded_groups WHERE ID_group = NEW.ID_group;
        DELETE FROM hiatus_groups WHERE ID_group = NEW.ID_group;
    ELSIF NEW.status = 'DISBANDED' THEN
        INSERT INTO disbanded_groups(ID_group) 
        VALUES(NEW.ID_group)
        ON CONFLICT (ID_group) DO NOTHING;
        DELETE FROM active_groups WHERE ID_group = NEW.ID_group;
        DELETE FROM hiatus_groups WHERE ID_group = NEW.ID_group;
    ELSIF NEW.status = 'HIATUS' THEN
        INSERT INTO hiatus_groups(ID_group) 
        VALUES(NEW.ID_group)
        ON CONFLICT (ID_group) DO NOTHING;
        DELETE FROM active_groups WHERE ID_group = NEW.ID_group;
        DELETE FROM disbanded_groups WHERE ID_group = NEW.ID_group;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_group_status_changed
AFTER INSERT OR UPDATE OF status ON groups
FOR EACH ROW EXECUTE FUNCTION group_status_changed();

CREATE OR REPLACE VIEW view_idol_age AS 
SELECT ID_idol, stage_name, EXTRACT(YEAR FROM AGE(CURRENT_DATE, birthday))::INT AS age
FROM idols;

CREATE OR REPLACE VIEW view_total_score AS
SELECT 
    ID_group, scraped_at,
    (COALESCE(dance_score, 0) + 
     COALESCE(vocal_score, 0) +  
     COALESCE(stage_score, 0) + 
     COALESCE(artistry_score, 0) +
     COALESCE(visual_score, 0)) AS total_score
FROM group_metrics;