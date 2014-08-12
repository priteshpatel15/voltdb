-- Eventually, this should evolve into a superset of the DDL for all the schema in all the configurations
-- used with sqlcoverage. Then we could avoid bouncing the server between templates.

CREATE TABLE P1 (
  ID INTEGER NOT NULL,
  DESC VARCHAR(15 BYTES),
  NUM INTEGER,
  RATIO FLOAT,
  PRIMARY KEY (ID)
);
PARTITION TABLE P1 ON COLUMN ID;

CREATE TABLE P2 (
  ID INTEGER NOT NULL,
  DESC VARCHAR(15 BYTES),
  NUM INTEGER,
  RATIO FLOAT,
  PRIMARY KEY (ID)
);
PARTITION TABLE P2 ON COLUMN ID;

CREATE TABLE R1 (
  ID INTEGER NOT NULL,
  DESC VARCHAR(15 BYTES),
  NUM INTEGER,
  RATIO FLOAT,
  PRIMARY KEY (ID)
);

CREATE TABLE R2 (
  ID INTEGER NOT NULL,
  DESC VARCHAR(15 BYTES),
  NUM INTEGER,
  RATIO FLOAT,
  PRIMARY KEY (ID)
);

CREATE TABLE P_DECIMAL (
  ID INTEGER NOT NULL,
  CASH DECIMAL NOT NULL,
  CREDIT DECIMAL,
  RATIO FLOAT,
  PRIMARY KEY (ID)
);
PARTITION TABLE P_DECIMAL ON COLUMN ID;

CREATE TABLE R_DECIMAL (
  ID INTEGER NOT NULL,
  CASH DECIMAL NOT NULL,
  CREDIT DECIMAL,
  RATIO FLOAT,
  PRIMARY KEY (ID)
);

CREATE TABLE P_COUNT (
    ID INTEGER NOT NULL,
    POINTS INTEGER,
    PRIMARY KEY (ID)
);
PARTITION TABLE P_COUNT ON COLUMN ID;
CREATE ASSUMEUNIQUE INDEX IDX_P_COUNT_TREE ON P_COUNT (POINTS);

CREATE TABLE R_COUNT (
    ID INTEGER NOT NULL,
    POINTS INTEGER,
    PRIMARY KEY (ID)
);
CREATE UNIQUE INDEX IDX_R_COUNT_TREE ON R_COUNT (POINTS);

CREATE TABLE P_TIMESTAMP (
    ID INTEGER DEFAULT '0' NOT NULL,
    PAST TIMESTAMP NOT NULL,
    FUTURE TIMESTAMP,
    RATIO FLOAT,
    PRIMARY KEY (ID)
);
PARTITION TABLE P_TIMESTAMP ON COLUMN ID;

CREATE TABLE R_TIMESTAMP (
    ID INTEGER DEFAULT '0' NOT NULL,
    PAST TIMESTAMP NOT NULL,
    FUTURE TIMESTAMP,
    RATIO FLOAT,
    PRIMARY KEY (ID)
);

CREATE TABLE P_INTO_VIEW (
    ID INTEGER DEFAULT '0' NOT NULL,
    TINY TINYINT NOT NULL,
    SMALL SMALLINT,
    BIG BIGINT,
    PRIMARY KEY (ID)
);
PARTITION TABLE P_INTO_VIEW ON COLUMN ID;

CREATE VIEW P_MATVIEW
    (      BIG, ID, NUM,      TINYCOUNT,   SMALLCOUNT,   BIGCOUNT,   TINYSUM,   SMALLSUM   ) AS
    SELECT BIG, ID, COUNT(*), COUNT(TINY), COUNT(SMALL), COUNT(BIG), SUM(TINY), SUM(SMALL)
    FROM P_INTO_VIEW
    GROUP BY BIG, ID;

CREATE TABLE R_INTO_VIEW (
    ID INTEGER DEFAULT '0' NOT NULL,
    TINY TINYINT NOT NULL,
    SMALL SMALLINT,
    BIG BIGINT,
    PRIMARY KEY (ID)
);

CREATE VIEW R_MATVIEW
    (      BIG, ID, NUM,      TINYCOUNT,   SMALLCOUNT,   BIGCOUNT,   TINYSUM,   SMALLSUM   ) AS
    SELECT BIG, ID, COUNT(*), COUNT(TINY), COUNT(SMALL), COUNT(BIG), SUM(TINY), SUM(SMALL)
    FROM R_INTO_VIEW
    WHERE ID > 5
    GROUP BY BIG, ID;
