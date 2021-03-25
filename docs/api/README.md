<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [API Documentation](#api-documentation)
    - [Developers Note](#developers-note)
    - [Backwards incompatable changes](#backwards-incompatable-changes)
    - [Updating content](#updating-content)
    - [Updating the template](#updating-the-template)
    - [Running documentation locally](#running-documentation-locally)
        - [Preview changes](#preview-changes)
    - [Publishing changes](#publishing-changes)
    - [License](#license)

<!-- markdown-toc end -->

# API Documentation

## Developers Note

The API work is in progess, and will change alonside the new requirements of the
application. As of now, it is only intended for evolving [Content Data
Admin](https://github.com/alphagov/content-data-admin), but in the long term,
once we have an stable version of the API, will be shareble across GOV.UK.

## Backwards incompatable changes

Currently the API is in alpha, so users should expect backwards incompatable changes without warning.

When the API is live, we will follow the [GDS API technical and data standards](https://www.gov.uk/guidance/gds-api-technical-and-data-standards#iterate-your-api)
- make backwards compatible changes where possible
- use a version number as part of the URL when making backwards incompatible changes
- make a new endpoint available for significant changes
- provide notices for deprecated endpoints

This is a middleman powered microsite for the API documentation. It
it is hosted by Github Pages and will eventually be available at https://content-data-api.publishing.service.gov.uk.

This documentation is built from source files in this repository and an
[OpenAPI specification file](https://github.com/OAI/OpenAPI-Specification), which is used to generate the reference section.

The framework for this documentation
is provided by the [GOV.UK Tech Docs Template][tech-docs-template] and through
the use of a [fork][forked-widdershins] of [widdershins][widdershins] to
convert the [`openapi.yaml`][openapi] to Markdown.

## Updating content
You can suggest edits by making changes in a branch or fork of this project and then opening a pull request.

The [`reference.html`][reference-page] page is built using the [`openapi.yaml`][openapi] file.

OpenAPI is similar to JSON schema. It describes the requests and responses for each endpoint, so we should update it any time we change the API itself.

For more information, see the [OpenAPI specification on github](https://github.com/OAI/OpenAPI-Specification/blob/master/versions/3.0.0.md).

Some aspects of the reference.html
page are controlled by templates which are stored in the
[`/templates`][templates-dir] of this repository.

Other HTML pages are in the [`/source`][source-dir] of this repository and are
authored using Markdown.

## Updating the template

You can update to the latest version of [tech-docs-template][] by running:

```
bundle update govuk_tech_docs
```

Read [the changelog for the gem][gem-changelog] for the latest changes.

[gem-changelog]: https://github.com/alphagov/tech-docs-gem/blob/master/CHANGELOG.md

## Running documentation locally

All commands should be run from `docs/api`.

### Preview changes

Whilst writing documentation we can run a middleman server to preview how the
published version will look in the browser. After saving a change the preview in
the browser will automatically refresh on HTML pages. However for changes to
[`openapi.yaml`][openapi] you will need to restart the preview.

The preview is only available on our own computer. Others won't be able to
access it if they are given the link.

Type the following to start the server:

```
make server API_SPEC=../../openapi.yaml
```

You should now be able to view a live preview at http://localhost:4567.

## Publishing changes

You can deploy with the following command:

```
make publish API_SPEC=../../openapi.yaml
```

This will push to the `gh-pages` branch and therefore deploy to GitHub Pages.

## License

[MIT License](LICENSE)

[forked-widdershins]: https://github.com/alphagov/widdershins
[widdershins]: https://github.com/Mermade/widdershins
[openapi]: https://github.com/alphagov/content-data-api/blob/master/openapi.yaml
[content-store]: https://github.com/alphagov/content-store
[templates-dir]: https://github.com/alphagov/govuk-content-api-docs/tree/master/templates
[source-dir]: https://github.com/alphagov/govuk-content-api-docs/tree/master/source
[reference-page]: https://content-api.publishing.service.gov.uk/reference.html
[tech-docs-template]: https://github.com/alphagov/tech-docs-template
[rvm]: https://www.ruby-lang.org/en/documentation/installation/#managers
[bundler]: http://bundler.io/
