CREATE SCHEMA `storage`;

CREATE SCHEMA `etexts`;

CREATE SCHEMA `images`;

CREATE TABLE `storage`.`objects` (
  `id` mediumint UNSIGNED PRIMARY KEY AUTO_INCREMENT COMMENT 'internal identifier',
  `bdrc_id` varchar(32) CHARACTER SET ascii NOT NULL COMMENT 'the BDRC RID (ex: W22084), unique persistent identifier, ASCII string no longer than 32 characters',
  `created_at` timestamp COMMENT 'the timestamp of the creation of the object, or the equivalent object in a previous archive storage',
  `last_modified_at` timestamp COMMENT 'the timestamp of the last known modification',
  `root_id` tinyint UNSIGNED NOT NULL COMMENT 'the OCFL stoage root id that the object is stored in'
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
  `file_id` int,
  `storage_object` mediumint UNSIGNED,
  `path` varchar(1024) CHARACTER SET utf8mb4 COMMENT 'Unicode string (256 Unicode characters max) representing the (case sensitive) content paths in OCFL objects for each content file.'
);

CREATE TABLE `etexts`.`file_info` (
  `content_file_id` int UNSIGNED PRIMARY KEY,
  `image_type` ENUM ('jpg', 'png', 'single_image_tiff', 'jp2') NOT NULL
);

CREATE TABLE `images`.`file_infos` (
  `content_file_id` int UNSIGNED PRIMARY KEY,
  `image_type` ENUM ('jpg', 'png', 'single_image_tiff', 'jp2') NOT NULL,
  `image_mode` ENUM ('1', 'L', 'RGB', 'RGBA', 'CMYK', 'P', 'OTHER') NOT NULL,
  `tiff_compression` ENUM ('raw', 'tiff_ccitt', 'group3', 'group4', 'tiff_lzw', 'tiff_jpeg', 'jpeg', 'tiff_adobe_deflate', 'lzma', 'other') COMMENT 'names are from PIL version 10',
  `width` smallint UNSIGNED NOT NULL COMMENT 'width of the bitmap (not taking a potential exif rotation into account)',
  `height` smallint UNSIGNED NOT NULL COMMENT 'height of the bitmap (not taking a potential exif rotation into account)',
  `quality` tinyint COMMENT 'relevant only for jpg, png and single_image_tiff encoded as jpg: quality of encoding. JPEG is represented between 0 and 100. For PNG this column encodes the compression between 0 and 9.',
  `bps` tinyint UNSIGNED NOT NULL COMMENT 'bits per sample',
  `recorded_date` timestamp COMMENT 'the timestamp recorded in the metadata'
);

CREATE UNIQUE INDEX ``storage`.objects_index_0` ON `storage`.`objects` (`bdrc_id`, `root_id`);

CREATE UNIQUE INDEX ``storage`.files_index_1` ON `storage`.`files` (`sha256`, `size`);

ALTER TABLE `storage`.`objects` COMMENT = 'Objects kept on archive storage';

ALTER TABLE `storage`.`roots` COMMENT = 'Storage roots';

ALTER TABLE `storage`.`files` COMMENT = 'Table of all the (deduplicated) actual files handled by Archive Storage';

ALTER TABLE `storage`.`paths` COMMENT = 'Table connecting files and their content paths in storage objects';

ALTER TABLE `images`.`file_infos` COMMENT = 'Table containing information about image files';

ALTER TABLE `storage`.`objects` ADD FOREIGN KEY (`root_id`) REFERENCES `storage`.`roots` (`id`);

ALTER TABLE `storage`.`paths` ADD FOREIGN KEY (`file_id`) REFERENCES `storage`.`files` (`id`);

ALTER TABLE `storage`.`paths` ADD FOREIGN KEY (`storage_object`) REFERENCES `storage`.`objects` (`id`);

ALTER TABLE `etexts`.`file_info` ADD FOREIGN KEY (`content_file_id`) REFERENCES `storage`.`files` (`id`);

ALTER TABLE `images`.`file_infos` ADD FOREIGN KEY (`content_file_id`) REFERENCES `storage`.`files` (`id`);
