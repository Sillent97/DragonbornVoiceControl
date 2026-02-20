cmake_minimum_required(VERSION 3.21)

execute_process(COMMAND "${CMAKE_COMMAND}" -E make_directory "${STAGE_ROOT}/SKSE/Plugins")
execute_process(COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${PLUGIN_FILE}" "${STAGE_ROOT}/SKSE/Plugins/${PLUGIN_NAME}")

if(EXISTS "${PAPYRUS_SRC_DIR}")
  execute_process(COMMAND "${CMAKE_COMMAND}" -E make_directory "${STAGE_ROOT}/Scripts/Source")
  execute_process(COMMAND "${CMAKE_COMMAND}" -E copy_directory "${PAPYRUS_SRC_DIR}" "${STAGE_ROOT}/Scripts/Source")
endif()

if(EXISTS "${PAPYRUS_PEX_DIR}")
  execute_process(COMMAND "${CMAKE_COMMAND}" -E make_directory "${STAGE_ROOT}/Scripts")
  execute_process(COMMAND "${CMAKE_COMMAND}" -E copy_directory "${PAPYRUS_PEX_DIR}" "${STAGE_ROOT}/Scripts")
endif()

if(EXISTS "${ESP_FILE}")
  execute_process(COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${ESP_FILE}" "${STAGE_ROOT}/DragonbornVoiceControl.esp")
else()
  message(STATUS "Stage: ESP not found (optional): ${ESP_FILE}")
endif()

message(STATUS "Stage: done -> ${STAGE_ROOT}")
