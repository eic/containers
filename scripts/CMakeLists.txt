################################################################################
## Configure launcher scripts for our singularity apps
################################################################################

set(APPS 
  "ddsim"
  "geoConverter"
  "materialScan"
  "geoDisplay"
  "geoPluginRun"
  "teveDisplay"
  "ddeve"
  "g4FromXML"
  "geoDisplay"
  "listcomponents"
  "print_materials"
  "dumpBfield"
  "g4gdmlDisplay"
  "geoPluginRun"
  "materialBudget"
  "pyddg4"
  "dumpdetector"
  "graphicalScan"
  "root"
  "root-config"
  "rootbrowse"
  "rootls"
  "mongo"
  "mongod"
  "mongodump"
  "mongoexport"
  "mongoimport"
  "mongostat"
  )

set(APPS_ABSOLUTE_PATH "")

## Bind directive for known systems
set (OPT_BIND_DIRECTIVE "")
foreach(BIND_PATH ${INSTALL_BIND_PATH})
  if (NOT "${BIND_PATH} " EQUAL " " AND EXISTS ${BIND_PATH})
    set (OPT_BIND_DIRECTIVE "${OPT_BIND_DIRECTIVE} -B ${BIND_PATH}:${BIND_PATH} ")
  endif ()
endforeach()
message("Adding singularity bind directive: '${OPT_BIND_DIRECTIVE}'")

find_program(SINGULARITY singularity)

foreach(APP ${APPS})
  configure_file(launcher.in ${APP} @ONLY)
  configure_file(wrapper.in ${APP}_wrap @ONLY)
  set(APPS_ABSOLUTE_PATH ${APPS_ABSOLUTE_PATH} "${CMAKE_CURRENT_BINARY_DIR}/${APP}")
  set(APPS_ABSOLUTE_PATH ${APPS_ABSOLUTE_PATH} "${CMAKE_CURRENT_BINARY_DIR}/${APP}_wrap")
endforeach ()

configure_file(container_dev.in container_dev @ONLY)
configure_file(container_shell_wrap.in container_shell_wrap @ONLY)
set(APPS_ABSOLUTE_PATH ${APPS_ABSOLUTE_PATH} "${CMAKE_CURRENT_BINARY_DIR}/container_dev")
set(APPS_ABSOLUTE_PATH ${APPS_ABSOLUTE_PATH} "${CMAKE_CURRENT_BINARY_DIR}/container_shell_wrap")

################################################################################
## Install the launcher scripts to <prefix>/bin
################################################################################
install(PROGRAMS ${APPS_ABSOLUTE_PATH}
  DESTINATION "${INSTALL_BIN_DIR}" COMPONENT bin)


