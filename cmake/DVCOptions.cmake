include_guard(GLOBAL)

# -----------------------------
# Names
# -----------------------------
set(DVC_MOD_NAME "Dragonborn Voice Control" CACHE STRING "Main mod folder name")
set(DVC_RUNTIME_MOD_BASENAME "${DVC_MOD_NAME}" CACHE STRING "Runtime mod base folder name")

set(DVC_RUNTIME_NAME "DVCRuntime" CACHE STRING "PyInstaller --name")
set(DVC_PIPE_RUNTIME_DIRNAME "DVCRuntime" CACHE STRING "Folder name under SKSE/Plugins/")

# -----------------------------
# Build output roots
# -----------------------------
set(DVC_STAGE_ROOT "${CMAKE_BINARY_DIR}/_mod/${DVC_MOD_NAME}")
set(DVC_RUNTIME_BUILD_ROOT "${CMAKE_BINARY_DIR}/runtime")

# -----------------------------
# Sources
# -----------------------------
set(DVC_CPP_SRC_DIR "${CMAKE_SOURCE_DIR}/src")
set(DVC_RUNTIME_SRC_DIR "${CMAKE_SOURCE_DIR}/runtime")
set(DVC_PAPYRUS_SRC_DIR "${CMAKE_SOURCE_DIR}/papyrus/Source")

# Optional ESP
set(DVC_ESP_FILE "${CMAKE_SOURCE_DIR}/mod/DragonbornVoiceControl.esp" CACHE FILEPATH "Optional ESP to stage (if present)")

# -----------------------------
# Papyrus options
# -----------------------------
option(DVC_PAPYRUS_COMPILE "Compile .psc -> .pex during build" ON)

set(PAPYRUS_COMPILER "" CACHE FILEPATH "Path to PapyrusCompiler.exe")
set(PAPYRUS_FLAGS_FILE "" CACHE FILEPATH "Path to TESV_Papyrus_Flags.flg")
set(SKYRIM_PAPYRUS_SOURCE_DIR "" CACHE PATH "Skyrim Papyrus source directory (Data/Scripts/Source)")
set(SKYUI_PAPYRUS_SOURCE_DIR "" CACHE PATH "SkyUI Papyrus source directory (SKI_*.psc)")
set(PAPYRUS_EXTRA_IMPORT_DIRS "" CACHE STRING "Additional Papyrus import dirs (semicolon-separated)")

set(DVC_PAPYRUS_PEX_DIR "${CMAKE_BINARY_DIR}/papyrus/pex")

# -----------------------------
# Runtime options
# -----------------------------
set(DVC_PYTHON_VERSION "3.12.8" CACHE STRING "Python 3.12.x version for portable embeddable (Windows)")

set(DVC_REQ_VOSK        "${DVC_RUNTIME_SRC_DIR}/requirements/requirements-vosk.txt" CACHE FILEPATH "Requirements for Vosk runtime")
set(DVC_REQ_WHISPER_CPU "${DVC_RUNTIME_SRC_DIR}/requirements/requirements-whisper-cpu.txt" CACHE FILEPATH "Requirements for Whisper CPU runtime")
set(DVC_REQ_WHISPER_GPU "${DVC_RUNTIME_SRC_DIR}/requirements/requirements-whisper-gpu.txt" CACHE FILEPATH "Requirements for Whisper GPU runtime")

set(DVC_RUNTIME_ENTRY "${DVC_RUNTIME_SRC_DIR}/main.py" CACHE FILEPATH "Runtime entrypoint (Python)")

set(DVC_RUNTIME_EXTRA_FILES
  "check_audio_device.bat"
  "shout_grammar.json"
  "shouts_map.json"
  CACHE STRING "Semicolon-separated list of runtime extra files (relative to runtime/)"
)

option(DVC_BUILD_VOSK "Enable Vosk runtime targets" ON)
option(DVC_BUILD_WHISPER_CPU "Enable Whisper CPU runtime targets" ON)
option(DVC_BUILD_WHISPER_GPU "Enable Whisper GPU runtime targets" ON)

# Extra PyInstaller args per variant (semicolon list) 
set(DVC_PYI_EXTRA_VOSK "--collect-all;vosk" CACHE STRING "Extra PyInstaller args for Vosk variant (semicolon list)")
set(DVC_PYI_EXTRA_WHISPER_CPU "--collect-all;vosk" CACHE STRING "Extra PyInstaller args for Whisper CPU variant (semicolon list)")
set(DVC_PYI_EXTRA_WHISPER_GPU "--collect-all;vosk" CACHE STRING "Extra PyInstaller args for Whisper GPU variant (semicolon list)")

# Reproducibility: OFF by default (you asked to control versions via requirements)
option(DVC_PIP_UPGRADE "Upgrade pip/setuptools/wheel before installing requirements" OFF)
