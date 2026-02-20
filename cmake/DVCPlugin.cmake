include_guard(GLOBAL)

function(dvc_add_plugin_targets)
  find_package(CommonLibSSE CONFIG REQUIRED)

  if(EXISTS "${CMAKE_SOURCE_DIR}/plugintest/DVCshouts/CMakeLists.txt")
    add_subdirectory("plugintest/DVCshouts")
  endif()

  add_commonlibsse_plugin(${PROJECT_NAME} SOURCES
    "${DVC_CPP_SRC_DIR}/Plugin.cpp"
    "${DVC_CPP_SRC_DIR}/Logging.cpp"
    "${DVC_CPP_SRC_DIR}/GameLanguage.cpp"
    "${DVC_CPP_SRC_DIR}/Paths.cpp"
    "${DVC_CPP_SRC_DIR}/Settings.cpp"
    "${DVC_CPP_SRC_DIR}/Dialogue.cpp"
    "${DVC_CPP_SRC_DIR}/FavoritesWatcher.cpp"
    "${DVC_CPP_SRC_DIR}/VoiceHandle.cpp"
    "${DVC_CPP_SRC_DIR}/VoiceTrigger.cpp"
    "${DVC_CPP_SRC_DIR}/Runtime.cpp"
    "${DVC_CPP_SRC_DIR}/PipeClient.cpp"
    "${DVC_CPP_SRC_DIR}/ServerLauncher.cpp"
  )

  target_include_directories(${PROJECT_NAME} PRIVATE
    "${PROJECT_SOURCE_DIR}/include"
  )

  target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_23)
  target_precompile_headers(${PROJECT_NAME} PRIVATE "${CMAKE_SOURCE_DIR}/include/PCH.h")

  target_link_libraries(${PROJECT_NAME} PRIVATE Shlwapi)
  if(TARGET DVCshouts)
    target_link_libraries(${PROJECT_NAME} PRIVATE DVCshouts)
  endif()

endfunction()
