# The Flutter tooling requires that developers have a version of Visual Studio
# installed that includes CMake 3.14 or later. You should not increase this
# version, as doing so will cause the plugin to fail to compile for some
# customers of the plugin.
cmake_minimum_required(VERSION 3.15)

# Project-level configuration.
set(PROJECT_NAME "komodo_defi_framework")
project(${PROJECT_NAME} LANGUAGES CXX)

set(PLUGIN_NAME "${PROJECT_NAME}_plugin")

add_library(${PLUGIN_NAME} SHARED
    "mm2_plugin.cc"
)

# Invoke the build for native code shared with the other target platforms.
# This can be changed to accommodate different builds.
add_subdirectory("${CMAKE_CURRENT_SOURCE_DIR}/../src" "${CMAKE_CURRENT_BINARY_DIR}/shared")

apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
    CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

target_include_directories(${PLUGIN_NAME} INTERFACE
    "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)

# Copy KDF to $HOME/.local/bin only when an artifact exists for this host.
# Linux ARM64 has no KDF release artifact yet. Applications without swaps may
# build the plugin there, but x86_64 builds still require their pinned KDF.
set(FINAL_INSTALL_DIR "$ENV{HOME}/.local/bin")
set(KDF_PATH "${CMAKE_CURRENT_SOURCE_DIR}/bin/kdf")

if(NOT EXISTS "${KDF_PATH}" AND NOT CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64)$")
  message(FATAL_ERROR "KDF executable not found for ${CMAKE_SYSTEM_PROCESSOR}: ${KDF_PATH}")
endif()

if(EXISTS "${KDF_PATH}")
  add_custom_command(
      TARGET ${PLUGIN_NAME} POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy_if_different
          "${KDF_PATH}"
          "${FINAL_INSTALL_DIR}/kdf"
  )
endif()

# List of absolute paths to libraries that should be bundled with the plugin
set(mm2_bundled_libraries
    "${CMAKE_CURRENT_SOURCE_DIR}/libmm2.so"
    PARENT_SCOPE
)

# List of absolute paths to libraries that should be bundled with the plugin.
# This list could contain prebuilt libraries, or libraries created by an
# external build triggered from this build file.
set(KDF_BUNDLED_LIBRARIES $<TARGET_FILE:komodo_defi_framework>)
if(EXISTS "${KDF_PATH}")
  list(APPEND KDF_BUNDLED_LIBRARIES "${KDF_PATH}")
endif()
set(komodo_defi_framework_bundled_libraries ${KDF_BUNDLED_LIBRARIES} PARENT_SCOPE)
