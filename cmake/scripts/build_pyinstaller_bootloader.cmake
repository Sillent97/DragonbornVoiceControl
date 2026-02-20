cmake_minimum_required(VERSION 3.21)

if(NOT WIN32)
  message(STATUS "pyinstaller-bootloader-usvfs: skipped (Windows-only).")
  return()
endif()

# ---- Defaults ----
if(NOT DEFINED DVC_PYI_BOOTLOADER_VERSION OR DVC_PYI_BOOTLOADER_VERSION STREQUAL "")
  set(DVC_PYI_BOOTLOADER_VERSION "6.19.0")
endif()

if(NOT DEFINED DVC_PYI_BOOTLOADER_URL OR DVC_PYI_BOOTLOADER_URL STREQUAL "")
  set(DVC_PYI_BOOTLOADER_URL
    "https://github.com/pyinstaller/pyinstaller/archive/refs/tags/v${DVC_PYI_BOOTLOADER_VERSION}.zip"
  )
endif()

if(NOT DEFINED DVC_RUNTIME_BUILD_ROOT OR DVC_RUNTIME_BUILD_ROOT STREQUAL "")
  set(DVC_RUNTIME_BUILD_ROOT "${CMAKE_BINARY_DIR}/runtime")
endif()

if(NOT EXISTS "${DVC_PYI_BOOTLOADER_APPLY_SCRIPT}")
  message(FATAL_ERROR "pyinstaller-bootloader-usvfs: apply_unidiff.py not found: ${DVC_PYI_BOOTLOADER_APPLY_SCRIPT}")
endif()
if(NOT EXISTS "${DVC_PYI_BOOTLOADER_PATCH_FILE}")
  message(FATAL_ERROR "pyinstaller-bootloader-usvfs: patch file not found: ${DVC_PYI_BOOTLOADER_PATCH_FILE}")
endif()

if(NOT DEFINED DVC_HOST_PYTHON_EXE OR DVC_HOST_PYTHON_EXE STREQUAL "" OR NOT EXISTS "${DVC_HOST_PYTHON_EXE}")
  message(FATAL_ERROR
    "pyinstaller-bootloader-usvfs: host python not found.\n"
    "Install Python or ensure CMake finds Python3 interpreter."
  )
endif()

message(STATUS "pyinstaller-bootloader-usvfs: version = ${DVC_PYI_BOOTLOADER_VERSION}")
message(STATUS "pyinstaller-bootloader-usvfs: url     = ${DVC_PYI_BOOTLOADER_URL}")
message(STATUS "pyinstaller-bootloader-usvfs: python  = ${DVC_HOST_PYTHON_EXE}")

set(_cache_root "${DVC_RUNTIME_BUILD_ROOT}/_pyinstaller-bootloader-${DVC_PYI_BOOTLOADER_VERSION}")
set(_src_root   "${_cache_root}/src")
set(_bin_root   "${_cache_root}/bin")
set(_stamp_built "${_cache_root}/.stamp_built")

file(MAKE_DIRECTORY "${_cache_root}")
file(MAKE_DIRECTORY "${_src_root}")
file(MAKE_DIRECTORY "${_bin_root}")

set(_need_build TRUE)
if(EXISTS "${_stamp_built}" AND NOT DVC_PYI_BOOTLOADER_FORCE_REBUILD)
  set(_need_build FALSE)
endif()

if(NOT _need_build)
  message(STATUS "pyinstaller-bootloader-usvfs: cached build found -> ${_bin_root}")
  return()
endif()

message(STATUS "pyinstaller-bootloader-usvfs: building patched bootloader (v${DVC_PYI_BOOTLOADER_VERSION})")
message(STATUS "pyinstaller-bootloader-usvfs: cache -> ${_cache_root}")

set(_zip "${_cache_root}/pyinstaller-v${DVC_PYI_BOOTLOADER_VERSION}.zip")
message(STATUS "pyinstaller-bootloader-usvfs: downloading ${DVC_PYI_BOOTLOADER_URL}")

file(DOWNLOAD "${DVC_PYI_BOOTLOADER_URL}" "${_zip}" SHOW_PROGRESS STATUS _dlst)
list(GET _dlst 0 _dlcode)
if(NOT _dlcode EQUAL 0)
  list(GET _dlst 1 _dlmsg)
  message(FATAL_ERROR "pyinstaller-bootloader-usvfs: download failed: ${_dlmsg}")
endif()

# Clean extracted tree
if(EXISTS "${_src_root}")
  file(REMOVE_RECURSE "${_src_root}")
endif()
file(MAKE_DIRECTORY "${_src_root}")

message(STATUS "pyinstaller-bootloader-usvfs: extracting sources")
file(ARCHIVE_EXTRACT INPUT "${_zip}" DESTINATION "${_src_root}")

set(_pyi_src "${_src_root}/pyinstaller-${DVC_PYI_BOOTLOADER_VERSION}")
if(NOT IS_DIRECTORY "${_pyi_src}")
  file(GLOB _cand LIST_DIRECTORIES TRUE "${_src_root}/pyinstaller-*")
  list(LENGTH _cand _cand_n)
  if(_cand_n LESS 1)
    message(FATAL_ERROR "pyinstaller-bootloader-usvfs: sources not found after extract in ${_src_root}")
  endif()
  list(GET _cand 0 _pyi_src)
endif()

set(_target_c "${_pyi_src}/bootloader/src/pyi_main.c")
if(NOT EXISTS "${_target_c}")
  message(FATAL_ERROR "pyinstaller-bootloader-usvfs: target not found: ${_target_c}")
endif()

message(STATUS "pyinstaller-bootloader-usvfs: applying patch -> ${_target_c}")
execute_process(
  COMMAND "${DVC_HOST_PYTHON_EXE}" "${DVC_PYI_BOOTLOADER_APPLY_SCRIPT}"
    --patch "${DVC_PYI_BOOTLOADER_PATCH_FILE}"
    --file "${_target_c}"
  RESULT_VARIABLE _patch_rv
  OUTPUT_VARIABLE _patch_out
  ERROR_VARIABLE _patch_err
)
if(NOT _patch_rv EQUAL 0)
  message(FATAL_ERROR "pyinstaller-bootloader-usvfs: patch failed.\n${_patch_out}\n${_patch_err}")
endif()

message(STATUS "pyinstaller-bootloader-usvfs: building bootloader via waf (needs MSVC env!)")
execute_process(
  COMMAND "${DVC_HOST_PYTHON_EXE}" waf all
  WORKING_DIRECTORY "${_pyi_src}/bootloader"
  RESULT_VARIABLE _waf_rv
  OUTPUT_VARIABLE _waf_out
  ERROR_VARIABLE _waf_err
)
if(NOT _waf_rv EQUAL 0)
  message(FATAL_ERROR
    "pyinstaller-bootloader-usvfs: waf build failed.\n"
    "Run build from 'Developer Command Prompt for VS'.\n"
    "${_waf_out}\n${_waf_err}"
  )
endif()

set(_built_dir "${_pyi_src}/PyInstaller/bootloader/Windows-64bit-intel")
set(_run  "${_built_dir}/run.exe")
set(_runw "${_built_dir}/runw.exe")
if(NOT EXISTS "${_run}" OR NOT EXISTS "${_runw}")
  message(FATAL_ERROR "pyinstaller-bootloader-usvfs: built bootloader not found at ${_built_dir}")
endif()

file(COPY_FILE "${_run}"  "${_bin_root}/run.exe"  ONLY_IF_DIFFERENT)
file(COPY_FILE "${_runw}" "${_bin_root}/runw.exe" ONLY_IF_DIFFERENT)

file(WRITE "${_stamp_built}" "ok")
message(STATUS "pyinstaller-bootloader-usvfs: OK -> ${_bin_root}")
