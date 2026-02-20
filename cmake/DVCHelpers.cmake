include_guard(GLOBAL)

function(dvc_make_dir path)
  execute_process(COMMAND "${CMAKE_COMMAND}" -E make_directory "${path}")
endfunction()

function(dvc_copy_if_exists src dst)
  if(EXISTS "${src}")
    execute_process(COMMAND "${CMAKE_COMMAND}" -E copy_if_different "${src}" "${dst}")
  endif()
endfunction()

function(dvc_copy_dir_if_exists src dst)
  if(EXISTS "${src}")
    execute_process(COMMAND "${CMAKE_COMMAND}" -E copy_directory "${src}" "${dst}")
  endif()
endfunction()
