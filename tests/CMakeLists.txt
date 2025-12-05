cmake_minimum_required(VERSION 3.16)

include(FetchContent)
FetchContent_Declare(
  googletest
  URL https://github.com/google/googletest/archive/refs/heads/main.zip
)
FetchContent_MakeAvailable(googletest)

add_executable(test_sequencer
  test_sequencer.cpp
)

target_link_libraries(test_sequencer PRIVATE sequencer gtest_main)
target_include_directories(test_sequencer PRIVATE ${CMAKE_SOURCE_DIR}/src)

include(GoogleTest)
gtest_discover_tests(test_sequencer)
