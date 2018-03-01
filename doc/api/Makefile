requirements:
	npm install
	bundle install

clean:
	rm -rf build

api:
	$(if ${API_SPEC},,$(error Must specify path to the OpenAPI spec file in API_SPEC))
	./generate.js ${API_SPEC} source/reference.html.md.erb

html: requirements clean api
	PROJECT_ROOT=`pwd` bundle exec rake build

server: html
	PROJECT_ROOT=`pwd` bundle exec middleman server

publish: requirements clean api
	PROJECT_ROOT=`pwd` bundle exec rake publish

all: html

.PHONY: setup requirements clean api html server publish
