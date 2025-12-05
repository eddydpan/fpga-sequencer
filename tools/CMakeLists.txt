cmake_minimum_required(VERSION 3.16)

add_executable(mock_uart_sender
  mock_uart_sender.cpp
)

target_compile_features(mock_uart_sender PRIVATE cxx_std_17)

install(TARGETS mock_uart_sender RUNTIME DESTINATION bin)
