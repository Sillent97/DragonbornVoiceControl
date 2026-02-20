include_guard(GLOBAL)

function(dvc_add_stage_targets)
  add_custom_target(stage-mod
    DEPENDS ${PROJECT_NAME} papyrus
    COMMAND "${CMAKE_COMMAND}"
      -DSTAGE_ROOT:PATH=${DVC_STAGE_ROOT}
      -DPLUGIN_FILE:FILEPATH=$<TARGET_FILE:${PROJECT_NAME}>
      -DPLUGIN_NAME:STRING=$<TARGET_FILE_NAME:${PROJECT_NAME}>
      -DPAPYRUS_PEX_DIR:PATH=${DVC_PAPYRUS_PEX_DIR}
      -DPAPYRUS_SRC_DIR:PATH=${DVC_PAPYRUS_SRC_DIR}
      -DESP_FILE:FILEPATH=${DVC_ESP_FILE}
      -P "${CMAKE_SOURCE_DIR}/cmake/scripts/stage_mod.cmake"
    VERBATIM
  )
endfunction()
