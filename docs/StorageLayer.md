# The BDRC Archive Storage Layer (ASL)

This layer is not looking at any domain-specific content of files, but solely at files themselves.

## Structure

The Archive Storage has simple structure:

#### Storage root

The storage root is the root folder of an archive. Its properties are:
- object layout
- replications

#### Storage object

A storage object is a group of content files that has a unique identifier. Its properties are:
- unique identifier
- creation date
- last modification date
- BDRC identifier in the catalog database

#### Content file

A content file is a file in the usual sense. Its properties are:
- unique identifier
- size
- creation date
- digest

#### Content file path

Since content files can appear in multiple locations in the archive, we keep their (potentially multiple) paths in separately. A file path properties are:
- content file identifier
- storage object
- path

## Storage API

##### get_storage_object_id(BDRC_id, storage_root_id, create_if_not_exists=False) -> storage_object_id

If an object with the same BDRC id exists in the same storage root, it returns the ID of the existing object.

If `create_if_not_exists` is set to `True`

##### get_content_file_id(sha256=None, size=None, created_at=None, create_if_not_exists=False) -> content_file_id

Returns the content_file_id for a file, indicating its sha256 and size. 

If the file doesn't exist and `create_if_not_exists` is set to True, creates the file and returns its id, otherwise returns None.

##### get_content_file_paths(content_file_id=None, sha256=None, size=None, storage_object_id=None)

Get the paths for a content file, optionally restricting to an object. The content file must be 

##### get_content_file_paths_in_object(storage_object_id, get_content_file_info=False, restrict_to_prefix=None)

Get all the content file paths in an object, optionally restricting to paths starting with a certain prefix.

If `get_content_file_info` is set to `True`, also returns information about each content file (`sha256`, `size`, `created_at`).

##### store_content_file(source, content_file_id, storage_object_id, path_in_storage_object)

Stores the file content in the archive. `source` is a file-like object.

##### get_content_file(content_file_id, storage_object_id, path_in_storage_object, dest)

Download a content file in `dest`, which is a file-like object.

