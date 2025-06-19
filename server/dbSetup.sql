-- NOTE Table Examples

CREATE TABLE IF NOT EXISTS accounts (
    id VARCHAR(255) NOT NULL PRIMARY KEY COMMENT 'primary key',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Time Created',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Last Update',
    name VARCHAR(255) COMMENT 'User Name',
    email VARCHAR(255) UNIQUE COMMENT 'User Email',
    picture VARCHAR(255) COMMENT 'User Picture'
) default charset utf8mb4 COMMENT '';

CREATE TABLE quests (
    id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    description VARCHAR(255),
    difficulty VARCHAR(255),
    reward INT NOT NULL,
    location VARCHAR(255),
    completed BOOLEAN,
    completed_by_id INT NOT NULL
);

-- --------------

-- NOTE my attempts

-- --------------

SELECT *
FROM heroes
WHERE
    level > 4
    AND class = 'Sorcerer'
ORDER BY id
LIMIT 3;

-- NOTE correct answer
SELECT *
FROM heros
WHERE
    class = 'Sorcerer'
ORDER BY level DESC
LIMIT 3;

SELECT heroes.name, heroes.class, heroes.emoji, guilds.guildName, classes.skills
FROM heroes
    INNER JOIN guilds ON guilds.id = heroes.guildId
    INNER JOIN classes ON classes.type = heroes.class;

-- NOTE correct answer
SELECT
    name,
    class,
    emoji,
    guildName,
    skills
FROM heroes
    JOIN guilds ON guilds.id = heroes.guildId
    JOIN classes ON classes.type = heroes.class
ORDER BY name;

-- -------------

-- NOTE Codeworks Examples

-- -------------

SELECT *
FROM heroes
WHERE
    class = 'Sorcerer'
ORDER BY level DESC
LIMIT 3;

SELECT name, guildId, guildName
FROM heroes
    JOIN guilds ON guilds.id = heroes.guildId;

SELECT heroes.id, heroes.name, heroes.guildId, guilds.id, guilds.guildName
FROM heroes
    JOIN guilds ON guilds.id = heroes.guildId;