get_filename_component(INPUT_FILE "${INPUT_FILE}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_LIST_DIR}/..")
get_filename_component(OUTPUT_FILE "${OUTPUT_FILE}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_LIST_DIR}/..")
include("${INPUT_FILE}")
file(WRITE "${OUTPUT_FILE}" "bx ${BX_GIT_TAG}\nbimg ${BIMG_GIT_TAG}\nbgfx ${BGFX_GIT_TAG}\n")
