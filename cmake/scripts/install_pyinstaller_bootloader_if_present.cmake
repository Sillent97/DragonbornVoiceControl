cmake_minimum_required(VERSION 3.21)

if(NOT WIN32)
  message(STATUS "PyInstaller bootloader: skipped (Windows-only).")
  return()
endif()

# Defaults so script works even if not passed/defined
if(NOT DEFINED DVC_PYI_BOOTLOADER_VERSION OR DVC_PYI_BOOTLOADER_VERSION STREQUAL "")
  set(DVC_PYI_BOOTLOADER_VERSION "6.19.0")
endif()
if(NOT DEFINED DVC_RUNTIME_BUILD_ROOT OR DVC_RUNTIME_BUILD_ROOT STREQUAL "")
  set(DVC_RUNTIME_BUILD_ROOT "${CMAKE_BINARY_DIR}/runtime")
endif()

# Presence-based behavior: if cached binaries exist -> install, else -> log and skip.
set(_cache_root "${DVC_RUNTIME_BUILD_ROOT}/_pyinstaller-bootloader-${DVC_PYI_BOOTLOADER_VERSION}")
set(_bin_root   "${_cache_root}/bin")
set(_cached_run  "${_bin_root}/run.exe")
set(_cached_runw "${_bin_root}/runw.exe")

if(NOT EXISTS "${_cached_run}" OR NOT EXISTS "${_cached_runw}")
  message(STATUS
    "PyInstaller bootloader: patched binaries not found (${_bin_root}), skipping install. "
    "Build target 'pyinstaller-bootloader-usvfs' to enable MO2/USVFS fix."
  )
  return()
endif()

# Optional: check PyInstaller version in this variant python; if mismatch -> warn and skip
execute_process(
  COMMAND "${DVC_PYTHON_EXE}" -c "import PyInstaller; print(getattr(PyInstaller,'__version__',''))"
  RESULT_VARIABLE _ver_rv
  OUTPUT_VARIABLE _pyi_ver
  ERROR_VARIABLE _pyi_ver_err
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
if(NOT _ver_rv EQUAL 0)
  message(STATUS "PyInstaller bootloader: cannot import PyInstaller yet, skipping install.\n${_pyi_ver_err}")
  return()
endif()

if(NOT _pyi_ver STREQUAL "${DVC_PYI_BOOTLOADER_VERSION}")
  message(STATUS
    "PyInstaller bootloader: PyInstaller version '${_pyi_ver}' != '${DVC_PYI_BOOTLOADER_VERSION}', "
    "skipping patched bootloader install."
  )
  return()
endif()

set(_site "${DVC_PYTHON_ROOT}/Lib/site-packages")
set(_dst_dir "${_site}/PyInstaller/bootloader/Windows-64bit-intel")
set(_dst_stamp "${_dst_dir}/.dvc_bootloader_${DVC_PYI_BOOTLOADER_VERSION}_usvfs")

if(NOT EXISTS "${_dst_dir}")
  message(STATUS "PyInstaller bootloader: destination not found (${_dst_dir}), skipping.")
  return()
endif()

# Optional default for force flag
if(NOT DEFINED DVC_PYI_BOOTLOADER_FORCE_INSTALL)
  set(DVC_PYI_BOOTLOADER_FORCE_INSTALL OFF)
endif()

set(_need_install TRUE)
if(EXISTS "${_dst_stamp}" AND NOT DVC_PYI_BOOTLOADER_FORCE_INSTALL)
  set(_need_install FALSE)
endif()

if(_need_install)
  message(STATUS "PyInstaller bootloader: installing patched run.exe/runw.exe into ${_dst_dir}")
  file(COPY_FILE "${_cached_run}"  "${_dst_dir}/run.exe"  ONLY_IF_DIFFERENT)
  file(COPY_FILE "${_cached_runw}" "${_dst_dir}/runw.exe" ONLY_IF_DIFFERENT)
  file(WRITE "${_dst_stamp}" "ok")
else()
  message(STATUS "PyInstaller bootloader: already installed for this variant (stamp found).")
endif()
