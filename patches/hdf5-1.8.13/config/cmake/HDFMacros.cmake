#-------------------------------------------------------------------------------
MACRO (SET_GLOBAL_VARIABLE name value)
  set (${name} ${value} CACHE INTERNAL "Used to pass variables between directories" FORCE)
ENDMACRO (SET_GLOBAL_VARIABLE)

#-------------------------------------------------------------------------------
MACRO (IDE_GENERATED_PROPERTIES SOURCE_PATH HEADERS SOURCES)
  #set(source_group_path "Source/AIM/${NAME}")
  string (REPLACE "/" "\\\\" source_group_path ${SOURCE_PATH})
  source_group (${source_group_path} FILES ${HEADERS} ${SOURCES})

  #-- The following is needed if we ever start to use OS X Frameworks but only
  #--  works on CMake 2.6 and greater
  #set_property (SOURCE ${HEADERS}
  #       PROPERTY MACOSX_PACKAGE_LOCATION Headers/${NAME}
  #)
ENDMACRO (IDE_GENERATED_PROPERTIES)

#-------------------------------------------------------------------------------
MACRO (IDE_SOURCE_PROPERTIES SOURCE_PATH HEADERS SOURCES)
  #  install (FILES ${HEADERS}
  #       DESTINATION include/R3D/${NAME}
  #       COMPONENT Headers       
  #  )

  string (REPLACE "/" "\\\\" source_group_path ${SOURCE_PATH}  )
  source_group (${source_group_path} FILES ${HEADERS} ${SOURCES})

  #-- The following is needed if we ever start to use OS X Frameworks but only
  #--  works on CMake 2.6 and greater
  #set_property (SOURCE ${HEADERS}
  #       PROPERTY MACOSX_PACKAGE_LOCATION Headers/${NAME}
  #)
ENDMACRO (IDE_SOURCE_PROPERTIES)

#-------------------------------------------------------------------------------
MACRO (TARGET_NAMING libtarget libtype)
  if (WIN32)
    if (${libtype} MATCHES "SHARED")
      set_target_properties (${libtarget} PROPERTIES OUTPUT_NAME "${libtarget}dll")
    endif (${libtype} MATCHES "SHARED")
  endif (WIN32)
ENDMACRO (TARGET_NAMING)

#-------------------------------------------------------------------------------
MACRO (INSTALL_TARGET_PDB libtarget targetdestination targetcomponent)
  if (WIN32 AND MSVC)
    get_target_property (target_name ${libtarget} RELWITHDEBINFO_OUTPUT_NAME)
    install (
      FILES
          ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${CMAKE_BUILD_TYPE}/${CMAKE_IMPORT_LIBRARY_PREFIX}${target_name}.pdb
      DESTINATION
          ${targetdestination}
      CONFIGURATIONS RelWithDebInfo
      COMPONENT ${targetcomponent}
  )
  endif (WIN32 AND MSVC)
ENDMACRO (INSTALL_TARGET_PDB)

#-------------------------------------------------------------------------------
MACRO (INSTALL_PROGRAM_PDB progtarget targetdestination targetcomponent)
  if (WIN32 AND MSVC)
    get_target_property (target_name ${progtarget} RELWITHDEBINFO_OUTPUT_NAME)
    get_target_property (target_prefix ${progtarget} PREFIX)
    install (
      FILES
          ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${CMAKE_BUILD_TYPE}/${target_prefix}${target_name}.pdb
      DESTINATION
          ${targetdestination}
      CONFIGURATIONS RelWithDebInfo
      COMPONENT ${targetcomponent}
  )
  endif (WIN32 AND MSVC)
ENDMACRO (INSTALL_PROGRAM_PDB)

#-------------------------------------------------------------------------------
MACRO (HDF_SET_LIB_OPTIONS libtarget libname libtype)
  # message (STATUS "${libname} libtype: ${libtype}")
  if (${libtype} MATCHES "SHARED")
    if (WIN32)
      set (LIB_RELEASE_NAME "${libname}")
      set (LIB_DEBUG_NAME "${libname}_D")
    else (WIN32)
      set (LIB_RELEASE_NAME "${libname}")
      set (LIB_DEBUG_NAME "${libname}_debug")
    endif (WIN32)
  else (${libtype} MATCHES "SHARED")
    if (WIN32)
      set (LIB_RELEASE_NAME "lib${libname}")
      set (LIB_DEBUG_NAME "lib${libname}_D")
    else (WIN32)
      # if the generator supports configuration types or if the CMAKE_BUILD_TYPE has a value
      if (CMAKE_CONFIGURATION_TYPES OR CMAKE_BUILD_TYPE)
        set (LIB_RELEASE_NAME "${libname}")
        set (LIB_DEBUG_NAME "${libname}_debug")
      else (CMAKE_CONFIGURATION_TYPES OR CMAKE_BUILD_TYPE)
        set (LIB_RELEASE_NAME "lib${libname}")
        set (LIB_DEBUG_NAME "lib${libname}_debug")
      endif (CMAKE_CONFIGURATION_TYPES OR CMAKE_BUILD_TYPE)
    endif (WIN32)
  endif (${libtype} MATCHES "SHARED")
  
  set_target_properties (${libtarget}
      PROPERTIES
      DEBUG_OUTPUT_NAME          ${LIB_DEBUG_NAME}
      RELEASE_OUTPUT_NAME        ${LIB_RELEASE_NAME}
      MINSIZEREL_OUTPUT_NAME     ${LIB_RELEASE_NAME}
      RELWITHDEBINFO_OUTPUT_NAME ${LIB_RELEASE_NAME}
  )
  
ENDMACRO (HDF_SET_LIB_OPTIONS)

#-------------------------------------------------------------------------------
MACRO (TARGET_C_PROPERTIES wintarget addcompileflags addlinkflags)
  if (MSVC)
    TARGET_MSVC_PROPERTIES (${wintarget} "${addcompileflags} ${WIN_COMPILE_FLAGS}" "${addlinkflags} ${WIN_LINK_FLAGS}")
  else (MSVC)
    if (BUILD_SHARED_LIBS)
      set_target_properties (${wintarget}
          PROPERTIES
              COMPILE_FLAGS "${addcompileflags}"
              LINK_FLAGS "${addlinkflags}"
      ) 
    else (BUILD_SHARED_LIBS)
      set_target_properties (${wintarget}
          PROPERTIES
              COMPILE_FLAGS "${addcompileflags}"
              LINK_FLAGS "${addlinkflags}"
      ) 
    endif (BUILD_SHARED_LIBS)
  endif (MSVC)
ENDMACRO (TARGET_C_PROPERTIES)

#-------------------------------------------------------------------------------
MACRO (TARGET_MSVC_PROPERTIES wintarget addcompileflags addlinkflags)
  if (MSVC)
    if (BUILD_SHARED_LIBS)
      set_target_properties (${wintarget}
          PROPERTIES
              COMPILE_FLAGS "${addcompileflags}"
              LINK_FLAGS "${addlinkflags}"
      ) 
    else (BUILD_SHARED_LIBS)
      set_target_properties (${wintarget}
          PROPERTIES
              COMPILE_FLAGS "${addcompileflags}"
              LINK_FLAGS "${addlinkflags}"
      ) 
    endif (BUILD_SHARED_LIBS)
  endif (MSVC)
ENDMACRO (TARGET_MSVC_PROPERTIES)

#-------------------------------------------------------------------------------
MACRO (TARGET_FORTRAN_PROPERTIES forttarget addcompileflags addlinkflags)
  if (WIN32)
    TARGET_FORTRAN_WIN_PROPERTIES (${forttarget} "${addcompileflags} ${WIN_COMPILE_FLAGS}" "${addlinkflags} ${WIN_LINK_FLAGS}")
  endif (WIN32)
ENDMACRO (TARGET_FORTRAN_PROPERTIES)

#-------------------------------------------------------------------------------
MACRO (TARGET_FORTRAN_WIN_PROPERTIES forttarget addcompileflags addlinkflags)
  if (MSVC)
    if (BUILD_SHARED_LIBS)
      set_target_properties (${forttarget}
          PROPERTIES
              COMPILE_FLAGS "/dll ${addcompileflags}"
              LINK_FLAGS "/SUBSYSTEM:CONSOLE ${addlinkflags}"
      ) 
    else (BUILD_SHARED_LIBS)
      set_target_properties (${forttarget}
          PROPERTIES
              COMPILE_FLAGS "${addcompileflags}"
              LINK_FLAGS "/SUBSYSTEM:CONSOLE ${addlinkflags}"
      ) 
    endif (BUILD_SHARED_LIBS)
  endif (MSVC)
ENDMACRO (TARGET_FORTRAN_WIN_PROPERTIES)
