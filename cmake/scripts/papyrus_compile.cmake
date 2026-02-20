cmake_minimum_required(VERSION 3.21)

if(NOT DVC_PAPYRUS_COMPILE)
  message(STATUS "Papyrus: compilation disabled (DVC_PAPYRUS_COMPILE=OFF).")
  return()
endif()

if(NOT EXISTS "${PAPYRUS_COMPILER}")
  message(WARNING "Papyrus: PAPYRUS_COMPILER not set or not found -> skipping.")
  return()
endif()
if(NOT EXISTS "${PAPYRUS_FLAGS_FILE}")
  message(WARNING "Papyrus: PAPYRUS_FLAGS_FILE not set or not found -> skipping.")
  return()
endif()
if(NOT EXISTS "${DVC_PAPYRUS_SRC_DIR}")
  message(WARNING "Papyrus: papyrus source dir not found -> skipping.")
  return()
endif()

file(GLOB DVC_PSC_FILES "${DVC_PAPYRUS_SRC_DIR}/*.psc")
if(DVC_PSC_FILES STREQUAL "")
  message(WARNING "Papyrus: no .psc files in ${DVC_PAPYRUS_SRC_DIR} -> skipping.")
  return()
endif()

set(_imports "${DVC_PAPYRUS_SRC_DIR}")
if(EXISTS "${SKYRIM_PAPYRUS_SOURCE_DIR}")
  list(APPEND _imports "${SKYRIM_PAPYRUS_SOURCE_DIR}")
endif()
if(EXISTS "${SKYUI_PAPYRUS_SOURCE_DIR}")
  list(APPEND _imports "${SKYUI_PAPYRUS_SOURCE_DIR}")
endif()
if(NOT PAPYRUS_EXTRA_IMPORT_DIRS STREQUAL "")
  list(APPEND _imports ${PAPYRUS_EXTRA_IMPORT_DIRS})
endif()
list(REMOVE_DUPLICATES _imports)
string(JOIN ";" _import_joined ${_imports})
string(REPLACE ";" "\\;" _import_escaped "${_import_joined}")

file(MAKE_DIRECTORY "${DVC_PAPYRUS_PEX_DIR}")

foreach(_psc IN LISTS DVC_PSC_FILES)
  execute_process(
    COMMAND "${PAPYRUS_COMPILER}" "${_psc}"
            "-i=${_import_escaped}"
            "-o=${DVC_PAPYRUS_PEX_DIR}"
            "-f=${PAPYRUS_FLAGS_FILE}"
    RESULT_VARIABLE _rv
  )
  if(NOT _rv EQUAL 0)
    message(FATAL_ERROR "Papyrus compile failed: ${_psc}")
  endif()
endforeach()

message(STATUS "Papyrus: compiled to ${DVC_PAPYRUS_PEX_DIR}")
