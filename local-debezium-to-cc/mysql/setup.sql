drop table if exists `tests`;
CREATE TABLE `tests` (
    `id` BIGINT auto_increment PRIMARY KEY,
    `name` VARCHAR(255),
    `created_at` TIMESTAMP,
    `updated_at` TIMESTAMP
);
INSERT INTO tests (name, created_at, updated_at) VALUES
 ('Test 1', NOW(), NOW()),
 ('Test 2', NOW(), NOW()),
 ('Test 3', NOW(), NOW()),
 ('Test 4', NOW(), NOW()),
 ('Test 5', NOW(), NOW()),
 ('Test 6', NOW(), NOW()),
 ('Test 7', NOW(), NOW()),
 ('Test 8', NOW(), NOW()),
 ('Test 9', NOW(), NOW()),
 ('Test 10', NOW(), NOW());
