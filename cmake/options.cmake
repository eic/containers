################################################################################
## CMAKE Settings 
################################################################################
## make sure that the default is RELEASE
if (NOT CMAKE_BUILD_TYPE)
  set (CMAKE_BUILD_TYPE RelWithDebInfo CACHE STRING
      "Choose the type of build, options are: None Debug Release RelWithDebInfo."
      FORCE)
endif ()
## Offer the user the choice of overriding the installation directories
set(INSTALL_LIB_DIR lib CACHE PATH "Installation directory for libraries")
set(INSTALL_BIN_DIR bin CACHE PATH "Installation directory for executables")
set(INSTALL_INCLUDE_DIR include/${PROJECT_NAME} CACHE PATH "Installation directory for header files")
set(INSTALL_MODULE_DIR ${CMAKE_INSTALL_PREFIX}/../../etc/modulefiles CACHE PATH "Installation directory for module files")
set(INSTALL_BIND_PATH "/net" "/group" "/cache" "/work" "/volatile" CACHE PATH "Installation singularity bind path")
if(WIN32 AND NOT CYGWIN)
  set(DEF_INSTALL_CMAKE_DIR cmake)
else()
  set(DEF_INSTALL_CMAKE_DIR lib/cmake/${PROJECT_NAME})
endif()
set(INSTALL_CMAKE_DIR ${DEF_INSTALL_CMAKE_DIR} CACHE PATH
  "Installation directory for cmake files")
## Make relative paths absolute (useful when auto-generating cmake configuration
## files) Note: not including INSTALL_BIND_PATH on purpose as we should be giving absolute
## paths anyway
foreach(p LIB BIN INCLUDE CMAKE MODULE)
  set(var INSTALL_${p}_DIR)
  if(NOT IS_ABSOLUTE "${${var}}")
    set(${var} "${CMAKE_INSTALL_PREFIX}/${${var}}")
  endif()
endforeach()
## extra cmake modules
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} 
  "${PROJECT_SOURCE_DIR}/cmake/")
