
# How to run a 'swift' executable that supports the 'swift build' command.
SWIFT ?= swift
AWK ?= awk
MAKE ?= make

# How to run a working version of protoc
PROTOC ?= protoc

# Path to a source checkout of Google's protobuf project
# The conformance host program is built from these sources
PROTOBUF_PROJECT_DIR ?= ../protobuf

# If you have already build conformance-test-runner in
# a nearby directory, just set the full path here and
# we'll use it instead.
HOST = ${PROTOBUF_PROJECT_DIR}/conformance/conformance-test-runner

# Our conformance program executes those test cases
SWIFT_CONFORMANCE_PLUGIN = .build/debug/Conformance
SWIFT_CONFORMANCE_PLUGIN_SOURCES = Sources/conformance.pb.swift Sources/main.swift

.PHONY: default all build check clean host test update

default: build

all: build

build: $(SWIFT_CONFORMANCE_PLUGIN)

# The Conformance plugin reads test cases from standard input,
# evaluates them, then writes the results back to standard output.
$(SWIFT_CONFORMANCE_PLUGIN): $(SWIFT_CONFORMANCE_PLUGIN_SOURCES)
	${SWIFT} build

check: test

test: $(SWIFT_CONFORMANCE_PLUGIN) $(HOST) failure_list_swift.txt
	( \
		ABS_PBDIR=`cd ${PROTOBUF_PROJECT_DIR}; pwd`; \
		$${ABS_PBDIR}/conformance/conformance-test-runner --failure_list failure_list_swift.txt $(SWIFT_CONFORMANCE_PLUGIN); \
	)

# The 'host' program is part of the protobuf project.
# It generates test cases, feeds them to our plugin, and verifies the results:
host: $(HOST)

$(HOST):
	( \
		cd ${PROTOBUF_PROJECT_DIR}; \
		./configure; \
		$(MAKE) -C src; \
		$(MAKE) -C conformance; \
	)

clean:
	rm -rf .build

update:
	swift package update

regenerate:
	ABS_PBDIR=`cd ${PROTOBUF_PROJECT_DIR}; pwd`; \
	${PROTOC} --swift_out=Sources -I $${ABS_PBDIR}/conformance -I $${ABS_PBDIR}/src $${ABS_PBDIR}/conformance/conformance.proto; \
	${PROTOC} --swift_out=Sources -I $${ABS_PBDIR}/src $${ABS_PBDIR}/src/google/protobuf/descriptor.proto; \
	${PROTOC} --swift_out=Sources -I $${ABS_PBDIR}/src $${ABS_PBDIR}/src/google/protobuf/source_context.proto;
