################################################################################
## Download the container
################################################################################

set(CONTAINER_SOURCE
  "https://eicweb.phy.anl.gov/containers/eic_container/-/jobs/artifacts/v${PROJECT_VERSION}/raw/build/eic.sif?job=eic_singularity")

add_custom_command(OUTPUT ${CONTAINER} 
  COMMAND wget ${CONTAINER_SOURCE} -O ${CONTAINER}
  COMMENT "Downloading ${CONTAINER}"
)

################################################################################
## Global target
################################################################################
add_custom_target(container ALL 
  DEPENDS ${CONTAINER})

################################################################################
## Install the container to <prefix>/lib
################################################################################
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${CONTAINER}
  DESTINATION "${INSTALL_LIB_DIR}" COMPONENT lib)
