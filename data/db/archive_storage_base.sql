CREATE SCHEMA `storage`;

CREATE SCHEMA `ocfl_storage`;

CREATE SCHEMA `etexts`;

CREATE SCHEMA `images`;

CREATE TABLE `storage`.`objects` (
  `id` mediumint UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'internal identifier',
  `bdrc_id` varchar(32) CHARACTER SET ascii NOT NULL COMMENT 'the BDRC RID (ex: W22084), unique persistent identifier, ASCII string no longer than 32 characters',
  `created_at` timestamp COMMENT 'the timestamp of the creation of the object, or the equivalent object in a previous archive storage',
  `last_modified_at` timestamp COMMENT 'the timestamp of the last known modification',
  `root` tinyint UNSIGNED NOT NULL COMMENT 'the OCFL stoage root id that the object is stored in'
);

CREATE TABLE `storage`.`roots` (
  `id` tinyint UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'internal identifier of the root object',
  `name` varchar(32) CHARACTER SET ascii NOT NULL COMMENT 'name of the Storage root (in ASCII), used to fint it on disk (ex: Archive0). The actual disk path depends on the mount points on the servers.',
  `layout` varchar(50) CHARACTER SET ascii NOT NULL COMMENT 'name of the storage layout, ASCII'
);

CREATE TABLE `storage`.`files` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `sha256` binary(32) NOT NULL COMMENT 'Digest. OCFL recommends sha512 but S3 only makes available sha256 so far',
  `size` bigint UNSIGNED NOT NULL COMMENT 'the size in bytes',
  `persistent_id` binary(32) UNIQUE NOT NULL COMMENT 'persistent identifier for the file, owned by Archive Storage. The identifier is globally unique for the BDRC archive. By construction it is the sha256 or a random id in case of collision.',
  `created_at` timestamp COMMENT 'the creation date of the file. Often unknown or unreliable, can be set to the earlier mtime exposed by the FS',
  `earliest_mdate` timestamp COMMENT 'the earliest modification date for the file (optional)'
);

CREATE TABLE `storage`.`paths` (
  `file` int UNSIGNED,
  `storage_object` mediumint UNSIGNED,
  `path` varchar(1024) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT 'Unicode string (256 Unicode characters max) representing the (case sensitive) content paths in OCFL objects for each content file.'
);

CREATE TABLE `ocfl_storage`.`users` (
  `id` smallint UNSIGNED PRIMARY KEY,
  `handle` varchar(16) CHARACTER SET ascii COMMENT 'A user name / handle for the command line',
  `name` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT 'A name for the user, limitted to 64 characters'
);

CREATE TABLE `etexts`.`file_info` (
  `storage_file` int PRIMARY KEY,
  `etext_type` ENUM ('doc', 'docx', 'tibet_doc', 'rtf', 'pdf', 'xml', 'tei_xml', 'txt', 'indd') NOT NULL,
  `nb_unicode_chars` mediumint UNSIGNED COMMENT 'the number of Unicode characters'
);

CREATE TABLE `ocfl_storage`.`transactions` (
  `id` mediumint,
  `storage_object` mediumint,
  `version` smallint COMMENT 'The OCFL version of the object',
  `created_at` timestamp NOT NULL COMMENT 'the transaction start time',
  `finished_at` timestamp NOT NULL COMMENT 'the transaction start time',
  `user` smallint NOT NULL COMMENT 'the user who started the transaction',
  PRIMARY KEY (`id`)
);

CREATE TABLE `ocfl_storage`.`versions` (
  `storage_object` mediumint UNSIGNED PRIMARY KEY,
  `version` smallint UNSIGNED COMMENT 'The OCFL version of the object',
  `created_at` timestamp NOT NULL COMMENT 'the creation time',
  `user` smallint UNSIGNED NOT NULL COMMENT 'the user who created the version',
  `message` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin COMMENT 'the message of the version in Unicode, truncated to 64 characters'
);

CREATE TABLE `ocfl_storage`.`objects_latest_version` (
  `storage_object` mediumint UNSIGNED PRIMARY KEY,
  `latest_version` smallint UNSIGNED NOT NULL COMMENT 'The latest OCFL version as integer'
);

CREATE TABLE `ocfl_storage`.`logical_paths` (
  `storage_file` int UNSIGNED,
  `storage_object` mediumint UNSIGNED,
  `object_version` smallint UNSIGNED NOT NULL COMMENT 'the version of the object that corresponds to this logical path'
);

CREATE TABLE `images`.`file_infos` (
  `storage_file` int UNSIGNED PRIMARY KEY,
  `image_type` ENUM ('jpg', 'png', 'single_image_tiff', 'jp2') NOT NULL,
  `image_mode` ENUM ('1', 'L', 'RGB', 'RGBA', 'CMYK', 'P', 'OTHER') NOT NULL,
  `tiff_compression` ENUM ('raw', 'tiff_ccitt', 'group3', 'group4', 'tiff_lzw', 'tiff_jpeg', 'jpeg', 'tiff_adobe_deflate', 'lzma', 'other') COMMENT 'names are from PIL version 10',
  `width` smallint UNSIGNED NOT NULL COMMENT 'width of the bitmap (not taking a potential exif rotation into account)',
  `height` smallint UNSIGNED NOT NULL COMMENT 'height of the bitmap (not taking a potential exif rotation into account)',
  `quality` tinyint UNSIGNED COMMENT 'relevant only for jpg, png and single_image_tiff encoded as jpg: quality of encoding. JPEG is represented between 0 and 100. For PNG this column encodes the compression between 0 and 9.',
  `bps` tinyint UNSIGNED NOT NULL COMMENT 'bits per sample',
  `recorded_date` timestamp COMMENT 'the timestamp recorded in the metadata'
);

CREATE UNIQUE INDEX ``storage`.objects_index_0` ON `storage`.`objects` (`bdrc_id`, `root`);

CREATE UNIQUE INDEX ``storage`.files_index_1` ON `storage`.`files` (`sha256`, `size`);

CREATE INDEX ``ocfl_storage`.transactions_index_0` ON `ocfl_storage`.`transactions` (`storage_object`);

CREATE UNIQUE INDEX ``ocfl_storage`.transactions_index_1` ON `ocfl_storage`.`transactions` (`storage_object`, `version`);

CREATE UNIQUE INDEX ``ocfl_storage`.ocfl_versions_index_0` ON `ocfl_storage`.`ocfl_versions` (`storage_object`, `version`);

CREATE UNIQUE INDEX ``ocfl_storage`.ocfl_versions_index_1` ON `ocfl_storage`.`ocfl_versions` (`transaction_number`);

ALTER TABLE `storage`.`objects` COMMENT = 'Objects kept on archive storage';

ALTER TABLE `storage`.`roots` COMMENT = 'Storage roots';

ALTER TABLE `storage`.`files` COMMENT = 'Table of all the (deduplicated) actual files handled by Archive Storage';

ALTER TABLE `storage`.`paths` COMMENT = 'Table connecting files and their content paths in storage objects';

ALTER TABLE `ocfl_storage`.`users` COMMENT = 'Users in the OCFL manifests';

ALTER TABLE `etexts`.`file_info` COMMENT = 'Domain-specific information record about relevant files (not every file needs to have an entry in this table)';

ALTER TABLE `ocfl_storage`.`transactions` COMMENT = 'A table recording the transactions to create OCFL versions';

ALTER TABLE `ocfl_storage`.`versions` COMMENT = 'A table recording the OCFL versions of all the objects';

ALTER TABLE `ocfl_storage`.`objects_latest_version` COMMENT = 'A table recording the most recent version of an OCFL object, as an integer';

ALTER TABLE `ocfl_storage`.`logical_paths` COMMENT = 'This table represents the logical state of each version (see OCFL spec)';

ALTER TABLE `images`.`file_infos` COMMENT = 'Table containing information about image files';

ALTER TABLE `storage`.`objects` ADD FOREIGN KEY (`root`) REFERENCES `storage`.`roots` (`id`);

ALTER TABLE `storage`.`paths` ADD FOREIGN KEY (`file`) REFERENCES `storage`.`files` (`id`);

ALTER TABLE `storage`.`paths` ADD FOREIGN KEY (`storage_object`) REFERENCES `storage`.`objects` (`id`);

ALTER TABLE `ocfl_storage`.`transactions` ADD FOREIGN KEY (`storage_object`) REFERENCES `storage`.`objects` (`id`);

ALTER TABLE `ocfl_storage`.`transactions` ADD FOREIGN KEY (`user`) REFERENCES `ocfl_storage`.`users` (`id`);

ALTER TABLE `etexts`.`file_info` ADD FOREIGN KEY (`content_file`) REFERENCES `storage`.`files` (`id`);

ALTER TABLE `ocfl_storage`.`versions` ADD FOREIGN KEY (`storage_object`) REFERENCES `storage`.`objects` (`id`);

ALTER TABLE `ocfl_storage`.`versions` ADD FOREIGN KEY (`user`) REFERENCES `ocfl_storage`.`users` (`id`);

ALTER TABLE `ocfl_storage`.`objects_latest_version` ADD FOREIGN KEY (`storage_object`) REFERENCES `storage`.`objects` (`id`);

ALTER TABLE `ocfl_storage`.`logical_paths` ADD FOREIGN KEY (`storage_file`) REFERENCES `storage`.`files` (`id`);

ALTER TABLE `ocfl_storage`.`logical_paths` ADD FOREIGN KEY (`storage_object`) REFERENCES `storage`.`objects` (`id`);

ALTER TABLE `images`.`file_infos` ADD FOREIGN KEY (`storage_file_id`) REFERENCES `storage`.`files` (`id`);
