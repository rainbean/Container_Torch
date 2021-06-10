cmake_minimum_required(VERSION 3.0 FATAL_ERROR)
project(Container_Torch)

# define library
find_package(TBB CONFIG REQUIRED)
target_link_libraries(main PRIVATE TBB::tbb)

message(STATUS "1: ${TBB_INCLUDE_DIRS}")
message(STATUS "2: ${TBB_LIBRARY_DIRS}")
message(STATUS "3: ${TBB_LIBRARIES}")
message(STATUS "4: ${TBB_INCLUDES}")
