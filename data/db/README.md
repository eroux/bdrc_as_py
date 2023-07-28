# BDRC storage and content databases

### Files in this directory

This directory contains a `.dbml` file that can be visualized on https://dbdiagram.io/ or used in different open source libraries. A `.sql` file is also present, derived from the previous one with some manual adjustments to indicate properties that cannot be represented in DBML (namesly `UNSIGNED` and `CHARACTER SET`).

### Design

##### Storage database

The BDRC storage database records information about all the files in the archive, for the purpose of file identification (unique identifier), fixity, storage node synchronization and general information about storage.

It is designed in a generic way so that it can accomodate different storage conventions (flat files, BagIt, OCFL, etc.).

We use a simple hierarchy:
- `storage.root`
   * `storage.object` (typically a "work")

and then have a table of files and paths. The database deduplicates files so that if a file is present in two paths in the archive, it will have only one entry in the `storage.files` database. The `storage.paths` table records all the paths of a file in the `storage.object`s. Each file has a unique ID in the database.

We use `sha256` as the digest for fixity check.

##### Image database

The image database records information on images 

##### Design details

We use 32 ASCII characters for the BDRC ID. As of July 2023:
- the longest digital instance BDRC id: `W0CDL0MS-ADD-01680-00002-00001` (30 bytes in ascii)
- the longest non-iiif digital instance BDRC id: `IE00EGS1016703` (14 bytes in ascii)
- the number of digital instances is 55,407 (54,109 non-iiif)