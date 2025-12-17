cmake_minimum_required(VERSION 3.16)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

add_library(sequencer
  sequencer_model.cpp
  uart_parser.cpp
  pitch_graph_widget.cpp
)

target_include_directories(sequencer PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(sequencer PUBLIC ${QT_LIBS})

add_executable(fpga_sequencer_gui
  main.cpp
  mainwindow.cpp
)

target_include_directories(fpga_sequencer_gui PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(fpga_sequencer_gui PRIVATE sequencer ${QT_LIBS})

install(TARGETS fpga_sequencer_gui RUNTIME DESTINATION bin)
