#!/bin/sh

curl "https://raw.githubusercontent.com/package-url/purl-spec/master/test-suite-data.json" | tee test/fixtures/test-suite-data-1.json
curl "https://raw.githubusercontent.com/package-url/packageurl-js/master/test/data/test-suite-data.json" | tee test/fixtures/test-suite-data-2.json

