# bgfx versioning scheme:
# bgfx 1.104.7082
#      ^ ^^^ ^^^^
#      | |   +--- Commit number  (https://github.com/bkaradzic/bgfx / git rev-list --count HEAD)
#      | +------- API version    (from https://github.com/bkaradzic/bgfx/blob/master/scripts/bgfx.idl#L4)
#      +--------- Major revision (always 1)
#
# BGFX_API_VERSION generated from https://github.com/bkaradzic/bgfx/blob/master/scripts/bgfx.idl#L4
# bgfx/src/version.h:
# BGFX_REV_NUMBER
# BGFX_REV_SHA1

find_package(Git QUIET)

if(EXISTS "${BGFX_DIR}/.git")
	if(NOT GIT_FOUND)
		message(FATAL_ERROR "Git is required to read the bgfx revision from ${BGFX_DIR}")
	endif()
	execute_process(
		COMMAND "${GIT_EXECUTABLE}" -C "${BGFX_DIR}" rev-parse --is-shallow-repository
		OUTPUT_VARIABLE BGFX_SHALLOW
		OUTPUT_STRIP_TRAILING_WHITESPACE
		RESULT_VARIABLE BGFX_GIT_RESULT
	)
	if(NOT BGFX_GIT_RESULT EQUAL 0 OR BGFX_SHALLOW STREQUAL "true")
		message(FATAL_ERROR "bgfx needs a complete Git history to compute its revision number: ${BGFX_DIR}")
	endif()
	execute_process(
		COMMAND "${GIT_EXECUTABLE}" -C "${BGFX_DIR}" rev-parse --short HEAD
		OUTPUT_VARIABLE GIT_REV
		OUTPUT_STRIP_TRAILING_WHITESPACE
		RESULT_VARIABLE BGFX_GIT_RESULT
	)
	if(NOT BGFX_GIT_RESULT EQUAL 0)
		message(FATAL_ERROR "Cannot read bgfx revision from ${BGFX_DIR}")
	endif()
	execute_process(
		COMMAND "${GIT_EXECUTABLE}" -C "${BGFX_DIR}" rev-list --count HEAD
		OUTPUT_VARIABLE GIT_REV_COUNT
		OUTPUT_STRIP_TRAILING_WHITESPACE
		RESULT_VARIABLE BGFX_GIT_RESULT
	)
	if(NOT BGFX_GIT_RESULT EQUAL 0 OR NOT GIT_REV_COUNT MATCHES "^[0-9]+$")
		message(FATAL_ERROR "Cannot count bgfx revisions in ${BGFX_DIR}")
	endif()
else()
	# Source archives contain version.h but no Git metadata.
	file(READ "${BGFX_DIR}/src/version.h" BGFX_VERSION_HEADER)
	string(REGEX MATCH "#define BGFX_REV_NUMBER[ \t]+([0-9]+)" _ "${BGFX_VERSION_HEADER}")
	set(GIT_REV_COUNT "${CMAKE_MATCH_1}")
	if(NOT GIT_REV_COUNT)
		message(FATAL_ERROR "Cannot find BGFX_REV_NUMBER in ${BGFX_DIR}/src/version.h")
	endif()
	string(REGEX MATCH "#define BGFX_REV_SHA1[ \t]+\"([^\"]+)\"" _ "${BGFX_VERSION_HEADER}")
	set(GIT_REV "${CMAKE_MATCH_1}")
endif()

# read version(100) from bgfx.idl
file(READ "${BGFX_DIR}/scripts/bgfx.idl" BGFX_IDL)
string(REGEX MATCH "version\\(([^\)]+)\\)" BGFX_API_VERSION ${BGFX_IDL})
set(BGFX_API_VERSION ${CMAKE_MATCH_1})
if(NOT BGFX_API_VERSION MATCHES "^[0-9]+$")
	message(FATAL_ERROR "Cannot read bgfx API version from ${BGFX_DIR}/scripts/bgfx.idl")
endif()
set(BGFX_REV_NUMBER ${GIT_REV_COUNT})
set(BGFX_REV ${GIT_REV})

# set project specific versions
set(PROJECT_VERSION 1.${BGFX_API_VERSION}.${BGFX_REV_NUMBER})
set(PROJECT_VERSION_MAJOR 1)
set(PROJECT_VERSION_MINOR ${BGFX_API_VERSION})
set(PROJECT_VERSION_PATCH ${BGFX_REV_NUMBER})
