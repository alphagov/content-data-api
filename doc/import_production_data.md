# Import Production Data

To import production data, follow the instructions at
[the GOV.UK developer docs](https://docs.publishing.service.gov.uk/manual/get-started.html#8-import-production-data)

## Note

The content_performance_manager database has grown very large and is
no longer imported by default.

There are some swiches you can provide to the replication script which
are documented when you run:

```
./replicate-data-local.sh -h
```

If you want to download/import only the content_performance_manager
database, add the following arguments to those given in the
instructions for both download and import:

```
-m -e -q -t -r -i "service-manual-publisher publishing_api link_checker_api email-alert-monitor content_data_admin content_tagger content_publisher organisations-publisher email-alert-api content-register content_audit_tool ckan local-links-manager support_contacts transition"
```

The important switches are:

`-m -e -q -t` - skip MongoDB, Elasticsearch, MySQL, Mapit

`-r` - reset the ignore list (import content_performance_manager which is ignored)

`-i "service-manual-publisher publishing_api ....` - ignore the other postgres databases
