################################################################################
##
## BCL to FASTQ file converter
## Copyright (c) 2007-2015 Illumina, Inc.
##
## This software is covered by the accompanying EULA
## and certain third party copyright/licenses, and any user of this
## source file is bound by the terms therein.
##
################################################################################
##
## file CMakeLists.txt
##
## Configuration file for boost installation
##
## author Come Raczy
##
################################################################################

macro (resetFindBoost)
    unset (Boost_FOUND CACHE)
    unset (Boost_INCLUDE_DIRS CACHE)
    unset (Boost_INCLUDE_DIR CACHE)
    unset (Boost_LIBRARIES CACHE)
    unset (Boost_LIBRARY_DIRS CACHE)
    unset (Boost_VERSION CACHE)
    unset (Boost_LIB_VERSION CACHE)
    unset (Boost_MAJOR_VERSION CACHE)
    unset (Boost_MINOR_VERSION CACHE)
    unset (Boost_SUBMINOR_VERSION CACHE)
    unset (Boost_USE_STATIC_LIBS CACHE) 

    unset (ENV{BOOST_LIBRARYDIR})
    unset (Boost_USE_MULTITHREADED CACHE)

    foreach (COMPONENT ${BCL2FASTQ_BOOST_COMPONENTS})
        STRING(TOUPPER ${COMPONENT} UPPERCOMPONENT)
        unset (Boost_${UPPERCOMPONENT}_FOUND CACHE)
        unset (Boost_${UPPERCOMPONENT}_LIBRARY CACHE)
        unset (Boost_${UPPERCOMPONENT}_LIBRARY_RELEASE CACHE)
        unset (Boost_${UPPERCOMPONENT}_LIBRARY_DEBUG CACHE)
    endforeach (COMPONENT ${BCL2FASTQ_BOOST_COMPONENTS})
    

    unset (Boost_FOUND)
    unset (Boost_INCLUDE_DIRS)
    unset (Boost_INCLUDE_DIR)
    unset (Boost_LIBRARIES)
    unset (Boost_LIBRARY_DIRS)
    unset (Boost_VERSION)
    unset (Boost_LIB_VERSION)
    unset (Boost_MAJOR_VERSION)
    unset (Boost_MINOR_VERSION)
    unset (Boost_SUBMINOR_VERSION)
    unset (Boost_USE_STATIC_LIBS)

    foreach (COMPONENT ${BCL2FASTQ_BOOST_COMPONENTS})
        STRING(TOUPPER ${COMPONENT} UPPERCOMPONENT)
        unset (Boost_${UPPERCOMPONENT}_FOUND)
        unset (Boost_${UPPERCOMPONENT}_LIBRARY)
        unset (Boost_${UPPERCOMPONENT}_LIBRARY_RELEASE)
        unset (Boost_${UPPERCOMPONENT}_LIBRARY_DEBUG)
    endforeach (COMPONENT ${BCL2FASTQ_BOOST_COMPONENTS})

endmacro (resetFindBoost)

#   
# Not only finds boost but also sets the variables so that
# it is being used for include and linking
# Also makes sure pthread is available for boost
#
macro(bcl2fastq_find_boost boost_version boost_components)

    # pthread library required by boost
    bcl2fastq_find_library(PTHREAD "pthread.h" pthread)
    if    (HAVE_PTHREAD)
        set  (BCL2FASTQ_ADDITIONAL_LIB ${BCL2FASTQ_ADDITIONAL_LIB} pthread)
        message(STATUS "pthread supported")
    else  (HAVE_PTHREAD)
        message(STATUS "pthread headers: ${PTHREAD_INCLUDE_DIR}")
        message(STATUS "pthread library: ${PTHREAD_LIBRARY}")
        message(FATAL_ERROR "pthread library is required to build the BCL2FASTQ")
    endif (HAVE_PTHREAD)

    find_package(Boost ${boost_version} REQUIRED ${boost_components})

    include_directories(BEFORE SYSTEM ${Boost_INCLUDE_DIRS})

    set      (HAVE_LIBBOOST_DATE_TIME       ${Boost_DATE_TIME_FOUND})
    set      (HAVE_LIBBOOST_FILESYSTEM      ${Boost_FILESYSTEM_FOUND})
    set      (HAVE_LIBBOOST_IOSTREAMS       ${Boost_IOSTREAMS_FOUND})
    set      (HAVE_LIBBOOST_PROGRAM_OPTIONS ${Boost_PROGRAM_OPTIONS_FOUND})
    set      (HAVE_LIBBOOST_PYTHON          ${Boost_PYTHON_FOUND})
    set      (HAVE_LIBBOOST_REGEX           ${Boost_REGEX_FOUND})
    set      (HAVE_LIBBOOST_SERIALIZATION   ${Boost_SERIALIZATION_FOUND})
    set      (HAVE_LIBBOOST_SYSTEM          ${Boost_SYSTEM_FOUND})
endmacro(bcl2fastq_find_boost)


if (BCL2FASTQ_FORCE_STATIC_LINK)
    set(Boost_USE_STATIC_LIBS ON) 
endif (BCL2FASTQ_FORCE_STATIC_LINK)

find_package(Boost ${BCL2FASTQ_BOOST_VERSION} COMPONENTS ${BCL2FASTQ_BOOST_COMPONENTS})
#
# If the right version of boost is not found, it will be built from the distribution
#
if (NOT Boost_FOUND)
    if (BOOSTROOT)
        message (STATUS "BOOSTROOT is set to ${BOOSTROOT} but boost ${BCL2FASTQ_BOOST_VERSION} was not found.")
        message (FATAL_ERROR "Unset BOOSTROOT or set it to the root location of boost ${BCL2FASTQ_BOOST_VERSION}.")
    endif(BOOSTROOT)
    if (BOOST_ROOT)
        message (STATUS "BOOST_ROOT is set to ${BOOST_ROOT} but boost ${BCL2FASTQ_BOOST_VERSION} was not found.")
        message (FATAL_ERROR "Unset BOOST_ROOT or set it to the root location of boost ${BCL2FASTQ_BOOST_VERSION}.")
    endif(BOOST_ROOT)

    # Try to find it in target installation location
    resetFindBoost()
    message(STATUS "Boost ${BCL2FASTQ_BOOST_VERSION} not found. Boost will be built from the distribution...")

    set(ENV{BCL2FASTQ_BOOST_COMPONENTS} "${BCL2FASTQ_BOOST_COMPONENTS}")
    set(ENV{BCL2FASTQ_BOOST_VERSION} "${BCL2FASTQ_BOOST_VERSION}")

    execute_process(COMMAND "/bin/bash"
"${CMAKE_SOURCE_DIR}/cmake/bootstrap/installBoost.sh" "${BOOST_REDIST_DIR}"
"${CMAKE_CURRENT_BINARY_DIR}/bootstrap" "${CMAKE_PARALLEL}"  RESULT_VARIABLE TMP_RESULT )

    if (NOT TMP_RESULT)
        message(STATUS "Successfuly built boost ${BCL2FASTQ_BOOST_VERSION} from the distribution package...")
    else (NOT TMP_RESULT)
        message (FATAL_ERROR "Failed to build boost ${BCL2FASTQ_BOOST_VERSION}")
    endif (NOT TMP_RESULT)

    set (BOOST_ROOT "${CMAKE_CURRENT_BINARY_DIR}/bootstrap")
    #the re-distributed boost uses system layout which means no -mt in file names.
    set (Boost_USE_MULTITHREADED OFF)
    #force static linking with redistributed boost.
    set (Boost_USE_STATIC_LIBS ON)

endif (NOT Boost_FOUND)


