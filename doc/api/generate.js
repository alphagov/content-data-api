#!/usr/bin/env node

var fs = require('fs');
var yaml = require('js-yaml');
var converter = require('widdershins');

var input_file = fs.readFileSync(process.argv[2], 'utf8');
var api = yaml.safeLoad(input_file, { json: true });

var options = {
  codeSamples: true,
  language_tabs: [
    { 'shell': 'Shell' }
  ],
  user_templates: 'templates',
  sample: true,
  templateCallback: function(templateName,stage,data) {
    if (templateName == "schema_sample" && stage == "pre") {
      appendSchemaDescription(data);
    }
    return data;
  }
}

function appendSchemaDescription(data) {
  var schemas = data.openapi.components.schemas;
  for(name in schemas) {
    var schema = schemas[name];
    if (schema.example != data.schema || !schema.description) {
      continue;
    }

    data.append = schema.description + "\n\n";
  }
}

converter.convert(api, options, function(err, output) {
	fs.writeFileSync(process.argv[3], output, 'utf8');
});
