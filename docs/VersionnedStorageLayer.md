# The BDRC Versionned Storage Layer (VSL)

The versionned storage layer is an optional layer sitting on top of the Archive Storage Layer. It is modelled after [OCFL v1.1](https://ocfl.io/1.1/spec/) but could use other similar conventions.

## Structure

The VSL adds two concepts to the ASL:
- storage object versions (positive integers)
- logical paths (with the same meaning as in the OCFL1.1 specification)
- per-object transactions

The transaction model works as follows:
- when starting the creation of a new version, a new version is created and is give

## API

##### get_latest_version(storage_object_id)

Returns the latest version of a versionned storage object as a positive integer. Returns None if the object is not versionned.

##### get_logical_paths(storage_object_id, version_number=0, get_content_file_info=False, restrict_to_prefix=None)

By convention, a version_number of `0` indicates the latest version. See `get_content_file_paths` for the meaning of `get_content_file_info` and `restrict_to_prefix`.

##### get_content_file(dest, storage_object_id, logical_path, version_number=0)

Download a content file in `dest`, which is a file-like object.

##### start_transaction(storage_object_id, user_id) -> transaction_id

Starts a transaction (creation of a new version), returns a transaction_id. 

Raises an exception if a transaction is already in progress.

##### complete_transaction(transaction_id, commit_message) -> version_number

Completes a transaction:
- creates the OCFL manifests
- updates the object's latest version reference
- removes references to the transaction in the database

##### abort_transaction(transaction_id)

Aborts a transaction:
- remove the version directory in the archive
- removes the logical paths of the version in the database
- removes references to the transaction in the database

##### set_logical_path(transaction_id, logical_path, content_file_id)

s