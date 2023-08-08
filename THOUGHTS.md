Content metadata (titles, authors, etc.) is not represented in AS but has a completely separate workflow. AS only stores files along with information on their encoding (file type, image encoding, etc.).

Digest: BDRC uses SHA256 as digest, since it can also be used for fixity check on S3 (while sha512 is not available on S3 at the time of experimentation)

https://wiki.lyrasis.org/display/FEDORA6x/Database+Cache

> All of Fedora's persistent content and metadata are stored on disk in an OCFL storage root. For performance reasons, Fedora maintains a cache of system and user metadata in a rebuildable database.

https://wiki.lyrasis.org/display/FEDORA6x/Internal+Database+Tables

https://wiki.lyrasis.org/display/FEDORA6x/Fedora+OCFL+Object+Structure


https://www.archivematica.org/en/docs/archivematica-1.14/user-manual/preservation/preservation-planning/#altering-commands-rules

identification: https://github.com/openpreserve/fido
characterization: custom Python script based on PIL
normalization: manual, validated by audit-tool


https://archivesspace.org/ stores documents in JsonModel (https://github.com/jsonmodel/jsonmodel) and stores them in a SOLR database

PREMIS, METS and LDP are useless, the only thing PREMIS brings is the mimetype and an exif data dump for images, but it doesn't store it in a very accessible way.

different options:
- full db including logical paths (this has some issues)
- partial db including only content files (should work)
- have content-specific (image, etext), be part of the files of each object (whether or not they are in the db)
- have generic analysis of the files (size, sha256, mimetype, characterization) be part of the files for each object


Description for each file:
- if in a separate inventory file, must be repeated for all logical paths in all versions, not ideal
- in an extension directory (best?)
- fcrepo stores it once per file -> less space, can be rebuilt

Object-level metadata?


engineering issue: version state in separate file (extension)?


```

```


difference is that we have a very detailed workflow with images and etexts, but no other workflow, so Archivematica, etc. are not good matches, they are not specific enough with images or etexts, and they provide other generic workflows we don't care about at the moment. They also don't provide any query that we're interested in.