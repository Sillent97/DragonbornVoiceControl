cmake_minimum_required(VERSION 3.21)

if(NOT WIN32)
  message(FATAL_ERROR "Runtime build is Windows-only (SKSE).")
endif()

if(EXISTS "${DVC_PYTHON_EXE}")
  message(STATUS "Python: already present -> ${DVC_PYTHON_EXE}")
  return()
endif()

file(MAKE_DIRECTORY "${DVC_RUNTIME_BUILD_ROOT}")
file(MAKE_DIRECTORY "${DVC_PYTHON_ROOT}")

set(_zip "${DVC_RUNTIME_BUILD_ROOT}/python-${DVC_PYTHON_VERSION}-embed-amd64.zip")
set(_url "https://www.python.org/ftp/python/${DVC_PYTHON_VERSION}/python-${DVC_PYTHON_VERSION}-embed-amd64.zip")

message(STATUS "Python(embeddable): downloading ${_url}")
file(DOWNLOAD "${_url}" "${_zip}" SHOW_PROGRESS STATUS _st)
list(GET _st 0 _code)
if(NOT _code EQUAL 0)
  list(GET _st 1 _msg)
  message(FATAL_ERROR "Python zip download failed: ${_msg}")
endif()

message(STATUS "Python(embeddable): extracting into ${DVC_PYTHON_ROOT}")
file(ARCHIVE_EXTRACT INPUT "${_zip}" DESTINATION "${DVC_PYTHON_ROOT}")


file(GLOB _pth_files "${DVC_PYTHON_ROOT}/python*._pth")
foreach(_pth IN LISTS _pth_files)
  file(REMOVE "${_pth}")
endforeach()

if(NOT EXISTS "${DVC_PYTHON_EXE}")
  message(FATAL_ERROR "Python unzip OK, but python.exe not found: ${DVC_PYTHON_EXE}")
endif()

message(STATUS "Python(embeddable): OK -> ${DVC_PYTHON_EXE}")

# Bootstrap pip
set(_getpip "${DVC_RUNTIME_BUILD_ROOT}/get-pip.py")
if(NOT EXISTS "${_getpip}")
  message(STATUS "Python(embeddable): downloading get-pip.py")
  file(DOWNLOAD "https://bootstrap.pypa.io/get-pip.py" "${_getpip}" SHOW_PROGRESS STATUS _gpst)
  list(GET _gpst 0 _gcode)
  if(NOT _gcode EQUAL 0)
    list(GET _gpst 1 _gmsg)
    message(FATAL_ERROR "get-pip.py download failed: ${_gmsg}")
  endif()
endif()

message(STATUS "Python(embeddable): installing pip")
execute_process(COMMAND "${DVC_PYTHON_EXE}" "${_getpip}" "--no-warn-script-location" RESULT_VARIABLE _pip_rv)
if(NOT _pip_rv EQUAL 0)
  message(FATAL_ERROR "pip bootstrap failed (rv=${_pip_rv}).")
endif()
