################################################################################
## Configure modulefile for our environment
################################################################################
set(MODULEFILE "${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}.${PROJECT_VERSION_PATCH}")
configure_file(modulefile.in ${MODULEFILE} @ONLY)

################################################################################
## Install the modulefile to <install_module_dir>/<project>/<version>
################################################################################
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${MODULEFILE}
  DESTINATION "${INSTALL_MODULE_DIR}/${PROJECT_NAME}" COMPONENT lib)
