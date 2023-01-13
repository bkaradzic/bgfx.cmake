# bgfx.cmake - bgfx building in cmake
# Written in 2017 by Joshua Brookover <joshua.al.brookover@gmail.com>
#
# To the extent possible under law, the author(s) have dedicated all copyright
# and related and neighboring rights to this software to the public domain
# worldwide. This software is distributed without any warranty.
#
# You should have received a copy of the CC0 Public Domain Dedication along with
# this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.

# Ensure the directory exists
if(NOT IS_DIRECTORY ${BX_DIR})
	message(SEND_ERROR "Could not load bx, directory does not exist. ${BX_DIR}")
	return()
endif()

include(GNUInstallDirs)

add_library(bx STATIC)

# Put in a "bgfx" folder in Visual Studio
set_target_properties(bx PROPERTIES FOLDER "bgfx")

# Build system specific configurations
if(MINGW)
	set(BX_COMPAT_PLATFORM mingw)
elseif(WIN32)
	set(BX_COMPAT_PLATFORM msvc)
elseif(APPLE) # APPLE is technically UNIX... ORDERING MATTERS!
	set(BX_COMPAT_PLATFORM osx)
elseif(UNIX)
	set(BX_COMPAT_PLATFORM linux)
endif()

# Add include directory of bx
target_include_directories(
	bx
	PUBLIC $<BUILD_INTERFACE:${BX_DIR}/include> #
		   $<BUILD_INTERFACE:${BX_DIR}/3rdparty> #
		   $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}> #
		   $<BUILD_INTERFACE:${BX_DIR}/include/compat/${BX_COMPAT_PLATFORM}> #
		   $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/compat/${BX_COMPAT_PLATFORM}> #
)

# Grab the bx source files
file(
	GLOB_RECURSE
	BX_SOURCES
	${BX_DIR}/include/*.h #
	${BX_DIR}/include/**.inl #
	${BX_DIR}/src/*.cpp #
	${BX_DIR}/scripts/*.natvis #
)

if(BX_AMALGAMATED)
	list(INSERT BX_NOBUILD "${BX_DIR}/src/allocator.cpp")
	list(INSERT BX_NOBUILD "${BX_DIR}/src/bounds.cpp")
	list(INSERT BX_NOBUILD "${BX_DIR}/src/bx.cpp")
	list(INSERT BX_NOBUILD "${BX_DIR}/src/commandline.cpp")
	list(INSERT BX_NOBUILD "${BX_DIR}/src/crtnone.cpp")
	list(INSERT BX_NOBUILD "${BX_DIR}/src/debug.cpp")
	list(INSERT BX_NOBUILD "${BX_DIR}/src/dtoa.cpp")
	list(INSERT BX_NOBUILD "${BX_DIR}/src/easing.cpp")
	list(INSERT BX_NOBUILD "${BX_DIR}/src/file.cpp")
	list(INSERT BX_NOBUILD "${BX_DIR}/src/filepath.cpp")
	list(INSERT BX_NOBUILD "${BX_DIR}/src/hash.cpp")
	list(INSERT BX_NOBUILD "${BX_DIR}/src/math.cpp")
	list(INSERT BX_NOBUILD "${BX_DIR}/src/mutex.cpp")
	list(INSERT BX_NOBUILD "${BX_DIR}/src/os.cpp")
	list(INSERT BX_NOBUILD "${BX_DIR}/src/process.cpp")
	list(INSERT BX_NOBUILD "${BX_DIR}/src/semaphore.cpp")
	list(INSERT BX_NOBUILD "${BX_DIR}/src/settings.cpp")
	list(INSERT BX_NOBUILD "${BX_DIR}/src/sort.cpp")
	list(INSERT BX_NOBUILD "${BX_DIR}/src/string.cpp")
	list(INSERT BX_NOBUILD "${BX_DIR}/src/thread.cpp")
	list(INSERT BX_NOBUILD "${BX_DIR}/src/timer.cpp")
	list(INSERT BX_NOBUILD "${BX_DIR}/src/url.cpp")
else()
	file(GLOB_RECURSE BX_NOBUILD "${BX_DIR}/src/amalgamated.*")
endif()

# Exclude files from the build but keep them in project
foreach(BX_SRC ${BX_NOBUILD})
	set_source_files_properties(${BX_SRC} PROPERTIES HEADER_FILE_ONLY ON)
endforeach()

# Add sources to the project
target_sources(bx PRIVATE ${BX_SOURCES})

# All configurations
target_compile_definitions(bx PUBLIC "BX_CONFIG_DEBUG=$<IF:$<CONFIG:Debug>,1,$<BOOL:${BX_CONFIG_DEBUG}>>")
target_compile_definitions(bx PUBLIC "__STDC_LIMIT_MACROS")
target_compile_definitions(bx PUBLIC "__STDC_FORMAT_MACROS")
target_compile_definitions(bx PUBLIC "__STDC_CONSTANT_MACROS")

target_compile_features(bx PUBLIC cxx_std_14)
# (note: see bx\scripts\toolchain.lua for equivalent compiler flag)
target_compile_options(bx PUBLIC $<$<CXX_COMPILER_ID:MSVC>:/Zc:__cplusplus>)

# Link against psapi on Windows
if(WIN32)
	target_link_libraries(bx PUBLIC psapi)
endif()

# Additional dependencies on Unix
if(ANDROID)
	# For __android_log_write
	find_library(LOG_LIBRARY log)
	mark_as_advanced(LOG_LIBRARY)
	target_link_libraries(bx PUBLIC ${LOG_LIBRARY})
elseif(APPLE)
	find_library(FOUNDATION_LIBRARY Foundation)
	mark_as_advanced(FOUNDATION_LIBRARY)
	target_link_libraries(bx PUBLIC ${FOUNDATION_LIBRARY})
elseif(UNIX)
	# Threads
	find_package(Threads)
	target_link_libraries(bx ${CMAKE_THREAD_LIBS_INIT} dl)

	# Real time (for clock_gettime)
	target_link_libraries(bx rt)
endif()

# Put in a "bgfx" folder in Visual Studio
set_target_properties(bx PROPERTIES FOLDER "bgfx")
