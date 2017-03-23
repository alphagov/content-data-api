# Set up API

To be able to use the API a few environment variables need to be set.

1) Create file `config/local_env.yml` (if the file does not exist yet)

2) Add an entry to `config/local_env.yml` for: `CONTENT-PERFORMANCE-MANAGER-TOKEN`

e.g.

```bash
CONTENT-PERFORMANCE-MANAGER-TOKEN: "1234567"
```

Use this the token value in any API request

# Samples

* Fetch details for a content item given a content id

```
curl -X "GET" "http://content-performance-manager.dev.gov.uk/content_items/ebd15ade-73b2-4eaf-b1c3-43034a42eb37.json" \
     -H "Content-Type: application/json"
```

* Create a group

```terminal
curl -X "POST" "http://content-performance-manager.dev.gov.uk/groups.json" \
     -H "Content-Type: application/json" \
     -d $'{
  "group": {
    "slug": "the-slug",
    "group_type": "the-group-type",
    "name": "the-name",
    "content_item_ids": [
      "content-id-1",
      "content-id-2"
    ],
    "parent_group_slug": "firstname49"
  },
  "api_token": "1234567"
}'
```

* Show a group

```terminal
curl "http://content-performance-manager.dev.gov.uk/groups/the-slug.json?api_token=1234567" \
     -H "Content-Type: application/json"
```

* List all groups

```terminal
curl "http://content-performance-manager.dev.gov.uk/groups.json?api_token=1234567" \
     -H "Content-Type: application/json"
```
