CREATE TABLE IF NOT EXISTS dim_time (
    id_time INT,
    full_date DATE NOT NULL UNIQUE,
    year INT NOT NULL,
    quarter INT NOT NULL,
    month INT NOT NULL,
    day INT NOT NULL,

    PRIMARY KEY(id_time)
);

CREATE TABLE IF NOT EXISTS dim_label (
    id_label INT,
    name VARCHAR(100) NOT NULL,
    founded_year INT,
    founder VARCHAR(100),

    PRIMARY KEY(id_label)
);

CREATE TABLE IF NOT EXISTS dim_group (
    id_group INT,
    group_name VARCHAR(100) NOT NULL,
    other_name VARCHAR(100),
    status VARCHAR(20),
    debut_date DATE,
    is_sub_unit BOOLEAN DEFAULT FALSE,

    PRIMARY KEY(id_group),
    CHECK(status IN ('ACTIVE', 'DISBANDED', 'HIATUS'))
);

CREATE TABLE IF NOT EXISTS dim_fandom (
    id_fandom INT,
    fandom_name VARCHAR(100),

    PRIMARY KEY(id_fandom)
);

CREATE TABLE IF NOT EXISTS fact_group_metrics (
    fact_id SERIAL,
    id_time INT NOT NULL,
    id_group INT NOT NULL,
    id_label INT,
    id_fandom INT,
    rank INT,
    total_bias_votes BIGINT,
    dance_score NUMERIC(5,2),
    vocal_score NUMERIC(5,2),
    stage_score NUMERIC(5,2),
    artistry_score NUMERIC(5,2),
    visual_score NUMERIC(5,2),
    total_score NUMERIC(5,2),
    scraped_at TIMESTAMP,

    PRIMARY KEY(fact_id),
    UNIQUE(id_group, id_time),
    FOREIGN KEY(id_time) REFERENCES dim_time(id_time) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY(id_group) REFERENCES dim_group(id_group) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY(id_label) REFERENCES dim_label(id_label) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY(id_fandom) REFERENCES dim_fandom(id_fandom) ON UPDATE CASCADE ON DELETE SET NULL
);
