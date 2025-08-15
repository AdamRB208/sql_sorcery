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

-- Order By
SELECT *
FROM heroes
WHERE
    level > 4
    AND class = 'Sorcerer'
ORDER BY id
LIMIT 3;

--  Correct Answer
SELECT *
FROM heros
WHERE
    class = 'Sorcerer'
ORDER BY level DESC
LIMIT 3;

-- Multiple Joins
SELECT heroes.name, heroes.class, heroes.emoji, guilds.guildName, classes.skills
FROM heroes
    INNER JOIN guilds ON guilds.id = heroes.guildId
    INNER JOIN classes ON classes.type = heroes.class;

-- Correct Answer
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

-- Group By
SELECT COUNT(heroes.id) AS memberCount
FROM guilds
    JOIN heroes ON guilds.id = heroes.id
GROUP BY
    guilds.guildName,
    guilds.banner,
ORDER BY memberCount DESC;

-- Correct Answer
SELECT guildName, banner, COUNT(heroes.id) AS memberCount
FROM guilds
    JOIN heroes ON heroes.guildId = guilds.id
GROUP BY
    guilds.id;

-- Group By W/Multiple Tables
SELECT guildName, banner, SUM(rewards) AS rewardSum
FROM guilds
    JOIN quests on quests.`completedById` = guilds.id
GROUP BY
    guilds.id;

-- Correct Answer
SELECT guildName, banner, SUM(quests.reward) AS rewardSum
FROM guilds
    JOIN quests ON quests.completedById = guilds.id
GROUP BY (guilds.id)
ORDER BY rewardSum DESC;

-- IF
SELECT
    guildName,
    banner,
    reputation,
    SUM(
        IF(
            class IN ('Assassins', 'Rogues'),
            1,
            0
        )
    ) AS criminals
FROM guilds
    JOIN heroes ON heroes.guildId = guilds.id
GROUP BY
    guilds.id
ORDER BY criminals;

-- Correct Answer
SELECT
    guildName,
    banner,
    reputation,
    SUM(
        IF(
            class IN ('Assassin', 'Rogue'),
            1,
            0
        )
    ) AS criminals
FROM guilds
    JOIN heroes ON heroes.guildId = guilds.id
GROUP BY
    guilds.id
HAVING
    criminals >= 1 -- Not needed but, removes any guilds that have 0 criminals
ORDER BY criminals DESC;

-- IF 2 W/IF & WHERE
SELECT guildName, banner, SUM(
        IF(
            quests.category = 'slaying', 1, 0
        )
    ) AS slayedCount
FROM guilds
    JOIN quests ON quests.completedById = guilds.id
GROUP BY
    guilds.id;

-- Correct Answers
SELECT guildName, banner, SUM(
        IF(
            quests.category = 'slaying', 1, 0
        )
    ) AS slayedCount
FROM guilds
    LEFT JOIN quests ON quests.completedById = guilds.id
GROUP BY
    guilds.id
LIMIT 1;

SELECT guildName, banner, COUNT(quests.id) AS slayedCount
FROM guilds
    LEFT JOIN quests ON quests.completedById = guilds.id
WHERE
    quests.category = 'slaying'
GROUP BY
    guilds.id
LIMIT 1;

-- VIEWS

CREATE VIEW `heroes_with_details` AS
SELECT heroes.*, guildName, skills,
FROM heroes
    JOIN guilds ON guilds.id = heroes.guildId
    JOIN classes ON heroes.class = classes.type;

-- CORRECT ANSWER
CREATE VIEW `heroes_with_details` AS
SELECT heroes.*, guildName, skills
FROM heroes
    LEFT JOIN guilds ON guilds.id = heroes.guildId
    LEFT JOIN classes ON heroes.class = classes.type;

-- Beyond Journeys End

-- OVERVIEW OF THE REALM
SELECT
    location,
    SUM(IF(difficulty = 'easy', 1, 0)) AS easy,
    SUM(
        IF(difficulty = 'medium', 1, 0)
    ) AS medium,
    SUM(IF(difficulty = 'hard', 1, 0)) AS hard,
    SUM(
        IF(difficulty = 'deadly', 1, 0)
    ) AS deadly
FROM quests
WHERE
    quests.completed = false
GROUP BY
    rewardTotal DESC;

-- Correct Answer
SELECT
    location,
    SUM(IF(difficulty = 'easy', 1, 0)) AS easy,
    SUM(
        IF(difficulty = 'medium', 1, 0)
    ) AS medium,
    SUM(IF(difficulty = 'hard', 1, 0)) AS hard,
    SUM(
        IF(difficulty = 'deadly', 1, 0)
    ) AS deadly,
    SUM(reward) AS rewardTotal
FROM quests
WHERE
    quests.completed = false
GROUP BY
    location
ORDER BY rewardTotal DESC;

-- DRAGON SLAYERS

SELECT
    guildName,
    banner,
    SUM(IF()) AS dragonsSlayed
FROM guilds
    JOIN quests ON quests.completedById = guilds.id
GROUP BY
    guilds.id;

-- CORRECT ANSWER

SELECT
    guildName,
    banner,
    SUM(
        IF(
            quests.description LIKE '%slay%dragon%',
            1,
            0
        )
    ) AS dragonsSlayed
FROM guilds
    JOIN quests ON quests.completedById = guilds.id
GROUP BY
    guilds.id
HAVING
    dragonsSlayed > 0
ORDER BY dragonsSlayed DESC;

-- HIGH VALUE TARGETS

-- CORRECT ANSWER

SELECT
    guildName,
    banner,
    COUNT(loot.id) AS itemCount,
    GROUP_CONCAT(loot.emoji SEPARATOR '-') AS items,
    SUM(loot.value) AS totalValue
FROM guilds
    LEFT JOIN quests ON guilds.id = quests.completedById
    LEFT JOIN loot on quests.id = loot.questId
GROUP BY
    guildName
ORDER BY totalValue DESC;

-- LEVEL UP HEROES
CREATE PROCEDURE IncreaseHeroLevel(IN leveledGuildId INT)
BEGIN 
UPDATE heroes SET
level = level + 1
WHERE `guildId` = leveledGuildId;
END$$

CREATE TRIGGER on_quests_update_level_up AFTER UPDATE
ON quests FOR EACH ROW
    BEGIN
    CALL levelUpHeroes(NEW.completedById);
END$$

-- CORRECT ANSWERS
-- PROCEDURE EXAMPLE
CREATE PROCEDURE LevelUpHeroes(IN leveledGuildId INT)
BEGIN

  UPDATE heroes SET
  level = level + 1
  WHERE guildId = leveledGuildId;

END$$

-- TRIGGER ANSWER
CREATE TRIGGER on_quests_update_level_up AFTER UPDATE
ON quests FOR EACH ROW
  BEGIN
    CALL levelUpHeroes(NEW.completedById);
  END$$

-- UPDATE ANSWER
UPDATE quests SET 
  completed = true, 
  completedById = 3 -- Emerald Order
WHERE id = 3;

-- NOTE Codeworks Examples

-- -------------

-- Join Example
SELECT name, guildId, guildName
FROM heroes
    JOIN guilds ON guilds.id = heroes.guildId;

-- Ambiguous Column Example
SELECT heroes.id, heroes.name, heroes.guildId, guilds.id, guilds.guildName
FROM heroes
    JOIN guilds ON guilds.id = heroes.guildId;

SELECT heroes.id, heroes.name, heroes.guildId, guilds.id, guilds.guildName
FROM heroes
    JOIN guilds ON guilds.id = heroes.guildId;
-- Count Example
SELECT COUNT(*) AS heroCount
FROM heroes
    JOIN classes ON classes.type = heroes.class
WHERE
    skills LIKE '%Magic%';

-- Sum Example
SELECT SUM(reputation) AS reputationSum FROM guilds;

-- Group Concat Example
SELECT GROUP_CONCAT(emoji) AS emojis FROM heroes;
--       OR
SELECT GROUP_CONCAT(DISTINCT class) AS allClasses FROM heroes;

-- Group By Examples
SELECT class, COUNT(*) AS count FROM heroes GROUP BY class;

--              W/Where Statement
SELECT location, COUNT(*) AS questCount
FROM quests
WHERE
    completed = false
GROUP BY
    location;

--               W/Join Statement
SELECT classes.type, COUNT(heroes.id) AS classCount
FROM classes
    JOIN heroes ON heroes.class = classes.type
GROUP BY
    classes.type
ORDER BY classCount DESC;
--
-- If Examples
SELECT guildName, banner, SUM(IF(level <= 5, 1, 0)) AS newbies -- adds 1 if true, adds 0 if false
FROM guilds
    JOIN heroes ON heroes.guildId = guilds.id
GROUP BY
    guilds.id;

SELECT
    guildName,
    banner,
    SUM(
        IF(
            class IN (
                'Mage',
                'Sorcerer',
                'Warlock',
                'Necromancer'
            ),
            1,
            0
        )
    ) AS spellCasters,
    SUM(
        IF(
            class IN (
                'Warrior',
                'Berserker',
                'Barbarian',
                'Ranger'
            ),
            1,
            0
        )
    ) AS fighters,
    SUM(
        IF(
            class IN ('Cleric', 'Paladin', 'Druid'),
            1,
            0
        )
    ) AS healers
FROM guilds
    JOIN heroes ON heroes.guildId = guilds.id
GROUP BY
    guilds.id;

-- VIEWS Examples

CREATE VIEW guilds_with_members AS
SELECT
    guilds.*, -- grabs all columns from just the guilds table
    COUNT(heroes.id) AS memberCount,
    GROUP_CONCAT(heroes.emoji) AS memberEmojis
FROM guilds
    LEFT JOIN heroes ON heroes.guildId = guilds.id
GROUP BY
    guilds.id;

SELECT
    guildName,
    banner,
    memberCount,
    COUNT(quests.id) AS questsCompleted
FROM guilds_with_members
    LEFT JOIN quests ON quests.completedById = guilds_with_members.id
GROUP BY
    guilds_with_members.id
ORDER BY questsCompleted DESC;

-- Procedures Examples

DELIMITER $$

CREATE PROCEDURE GetGuilds()
BEGIN
   SELECT 
     guilds.*,
     COUNT(heroes.id) AS memberCount
   FROM guilds
     LEFT JOIN heroes ON heroes.guildId = guilds.id
   GROUP BY guilds.id; -- because the delimiter change, our statement won't end here
END$$ -- it will end here, completing the procedure creation

DELIMITER ;

-- Call Example 

CALL GetGuilds();

-- get guild by id 
    -- procedure

CREATE PROCEDURE GetGuildById(IN targetId INT) 
BEGIN
   SELECT guilds.*,
      COUNT(heroes.id) AS memberCount
   FROM guilds
      LEFT JOIN heroes ON heroes.guildId = guilds.id
   WHERE guilds.id = targetId 
   GROUP BY guilds.id;
END $$

    -- call
CALL GetGuildById(2)

-- Update guild rep 
    -- procedure 
CREATE PROCEDURE UpdateGuildRep(IN targetId INT) 
BEGIN
   DECLARE newRep INT; -- create variable

   SELECT SUM(quests.reward) INTO newRep -- assign newRep a value
   FROM guilds
      LEFT JOIN quests ON quests.completedById = guilds.id
   WHERE guilds.id = targetId
   GROUP BY guilds.id;

   UPDATE guilds
   SET reputation = newRep -- update guild with newRep
   WHERE guilds.id = targetId;
END$$

    -- call
CALL UpdateGuildRep(1);

-- TRIGGERS Examples
DELIMITER $$
CREATE TRIGGER on_update_quests AFTER UPDATE -- name of trigger and when
ON quests FOR EACH ROW -- for which table
BEGIN -- body of trigger
  CALL UpdateGuildRep(NEW.completedById);
-- NEW, is unique to AFTER triggers, it represents the new data entered into the table
END $$

DELIMITER;

-- Update
UPDATE quests
SET
    completed = true,
    completedById = 3 -- Emerald Order id
WHERE
    id = 2;
-- quest id