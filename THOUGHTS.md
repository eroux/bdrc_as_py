Content metadata (titles, authors, etc.) is not represented in AS but has a completely separate workflow. AS only stores files along with information on their encoding (file type, image encoding, etc.).

Digest: BDRC uses SHA256 as digest, since it can also be used for fixity check on S3 (while sha512 is not available on S3 at the time of experimentation)