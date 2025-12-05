
cmake_minimum_required(VERSION 3.16)
project(fpga_sequencer LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(BUILD_TESTS "Build unit tests" ON)

# Find Qt6 or fallback to Qt5
find_package(Qt6 COMPONENTS Widgets QUIET)
if(Qt6_FOUND)
	set(QT_LIBS Qt6::Widgets)
else()
	find_package(Qt5 COMPONENTS Widgets REQUIRED)
	set(QT_LIBS Qt5::Widgets)
endif()

# Add source tree
add_subdirectory(src)

# Add tools (mock UART sender)
add_subdirectory(tools)

if(BUILD_TESTS)
	enable_testing()
	add_subdirectory(tests)
endif()
