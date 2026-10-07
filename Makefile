.DEFAULT_GOAL := help

SWIFT := swift
CONFIG := {"lineLength":120,"tabWidth":4,"indentation":{"tabs":1}}
SOURCES := ./Tanuki ./Tanuki\ Watch\ App ./Emoji

APOLLO_CONFIG := ./apollo-codegen-config.json
APOLLO_CLI := ./apollo-ios-cli
APOLLO_URL := https://github.com/apollographql/apollo-ios/releases/latest/download/apollo-ios-cli.tar.gz

.PHONY: help fmt lint check install-apollo-cli fetch-schema generate-apollo

help:
	@printf 'make fmt                 format sources in place\n'
	@printf 'make lint                report style issues\n'
	@printf 'make check               format, then lint\n'
	@printf 'make install-apollo-cli  download latest apollo-ios-cli\n'
	@printf 'make fetch-schema        refetch gitlab@current.graphqls\n'
	@printf 'make generate-apollo     regenerate GitLabAPI\n'

fmt:
	$(SWIFT) format -p -r -i --configuration '$(CONFIG)' $(SOURCES)

lint:
	@findings="$$($(SWIFT) format lint -p -r --configuration '$(CONFIG)' $(SOURCES) 2>&1)"; \
	if [ -n "$$findings" ]; then \
		printf '%s\n' "$$findings" >&2; \
		printf '\nlint failed (%s findings) - run make fmt\n' "$$(printf '%s\n' "$$findings" | wc -l | tr -d ' ')" >&2; \
		exit 1; \
	fi
	@printf 'lint passed\n'

check: fmt lint

install-apollo-cli: $(APOLLO_CLI)
	@$(APOLLO_CLI) --version

fetch-schema: | $(APOLLO_CLI)
	$(APOLLO_CLI) fetch-schema --path $(APOLLO_CONFIG)

generate-apollo: | $(APOLLO_CLI)
	$(APOLLO_CLI) generate --path $(APOLLO_CONFIG)

$(APOLLO_CLI):
	@tmpdir=$$(mktemp -d); \
	curl -sSfL $(APOLLO_URL) -o $$tmpdir/apollo-ios-cli.tar.gz && \
	tar -xzf $$tmpdir/apollo-ios-cli.tar.gz -C $$tmpdir && \
	bin=$$(find $$tmpdir -type f -name apollo-ios-cli | head -1); \
	cp $$bin $(APOLLO_CLI) && chmod +x $(APOLLO_CLI) && rm -rf $$tmpdir
