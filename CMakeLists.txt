
cmake_minimum_required(VERSION 3.16)
project(fpga_sequencer LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(BUILD_TESTS "Build unit tests" ON)

# Find Qt6 or fallback to Qt5
find_package(Qt6 COMPONENTS Widgets SerialPort QUIET)
if(Qt6_FOUND)
  set(QT_LIBS Qt6::Widgets Qt6::SerialPort)
  set(QT_FOUND TRUE)
else()
  find_package(Qt5 COMPONENTS Widgets QUIET)
  find_package(Qt5SerialPort QUIET)
  if(Qt5_FOUND)
    set(QT_LIBS Qt5::Widgets)
    if(Qt5SerialPort_FOUND)
      list(APPEND QT_LIBS Qt5::SerialPort)
      add_definitions(-DHAVE_QSERIALPORT)
    else()
      message(WARNING "Qt5SerialPort not found. Serial port functionality will be disabled.")
    endif()
    set(QT_FOUND TRUE)
  endif()
endif()

if(NOT QT_FOUND)
  message(FATAL_ERROR "Qt5 or Qt6 with Widgets component is required")
endif()# Add source tree
add_subdirectory(src)

# Add tools (mock UART sender)
add_subdirectory(tools)

if(BUILD_TESTS)
	enable_testing()
	add_subdirectory(tests)
endif()
