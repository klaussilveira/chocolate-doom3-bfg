#[=======================================================================[.rst:
FindDirectX
-----------

Finds DirectX SDK components on Windows.

On modern Windows (VS2015+), DirectX is part of the Windows SDK and
the headers/libraries are in the compiler's default search paths.

Imported Targets
^^^^^^^^^^^^^^^^

This module provides the following imported targets, if found:

``DirectX::DirectX``
  Combined interface target with all DirectX components

Result Variables
^^^^^^^^^^^^^^^^

This will define the following variables:

``DirectX_FOUND``
  True if DirectX components are available.
``DirectX_INCLUDE_DIRS``
  Include directories needed for DirectX (may be empty for Windows SDK).
``DirectX_LIBRARIES``
  Libraries needed to link to DirectX.

#]=======================================================================]

if(NOT WIN32)
    return()
endif()

# On modern Windows (VS2015+), DirectX is part of the Windows SDK.
# The headers and libraries are in the default compiler search paths.
# We first try to find them explicitly, then fall back to assuming
# they're available in the default paths.

# Determine library path suffix based on architecture
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(_DirectX_LIBPATH_SUFFIX "Lib/x64")
else()
    set(_DirectX_LIBPATH_SUFFIX "Lib/x86")
endif()

# Try to find include directory (may fail on modern Windows SDK where it's in default paths)
find_path(DirectX_INCLUDE_DIR
    NAMES dinput.h
    HINTS
        ENV DXSDK_DIR
        ENV WindowsSdkDir
    PATH_SUFFIXES
        Include
        Include/um
        Include/shared
    DOC "DirectX include directory"
)

# Try to find libraries
find_library(DirectX_DINPUT8_LIBRARY
    NAMES dinput8
    HINTS
        ENV DXSDK_DIR
        ENV WindowsSdkDir
    PATH_SUFFIXES
        ${_DirectX_LIBPATH_SUFFIX}
        Lib/${_DirectX_LIBPATH_SUFFIX}/um
    DOC "DirectInput 8 library"
)

find_library(DirectX_DSOUND_LIBRARY
    NAMES dsound
    HINTS
        ENV DXSDK_DIR
        ENV WindowsSdkDir
    PATH_SUFFIXES
        ${_DirectX_LIBPATH_SUFFIX}
        Lib/${_DirectX_LIBPATH_SUFFIX}/um
    DOC "DirectSound library"
)

find_library(DirectX_DXGUID_LIBRARY
    NAMES dxguid
    HINTS
        ENV DXSDK_DIR
        ENV WindowsSdkDir
    PATH_SUFFIXES
        ${_DirectX_LIBPATH_SUFFIX}
        Lib/${_DirectX_LIBPATH_SUFFIX}/um
    DOC "DirectX GUID library"
)

find_library(DirectX_XINPUT_LIBRARY
    NAMES xinput xinput9_1_0
    HINTS
        ENV DXSDK_DIR
        ENV WindowsSdkDir
    PATH_SUFFIXES
        ${_DirectX_LIBPATH_SUFFIX}
        Lib/${_DirectX_LIBPATH_SUFFIX}/um
    DOC "XInput library"
)

# Check if we're using MSVC with Windows SDK (modern setup)
# In this case, DirectX is available in default paths even if find_* failed
set(_DirectX_MODERN_SDK FALSE)
if(MSVC AND NOT DirectX_DINPUT8_LIBRARY)
    # Test if we can compile with DirectX headers from default paths
    include(CheckIncludeFile)
    check_include_file("dinput.h" _DirectX_HAS_DINPUT_H)
    if(_DirectX_HAS_DINPUT_H)
        set(_DirectX_MODERN_SDK TRUE)
    endif()
endif()

if(_DirectX_MODERN_SDK)
    # Modern Windows SDK - libraries are in default linker paths
    # Clear the NOTFOUND cache entries since we don't need explicit paths
    unset(DirectX_INCLUDE_DIR CACHE)
    unset(DirectX_DINPUT8_LIBRARY CACHE)
    unset(DirectX_DSOUND_LIBRARY CACHE)
    unset(DirectX_DXGUID_LIBRARY CACHE)
    unset(DirectX_XINPUT_LIBRARY CACHE)

    set(DirectX_FOUND TRUE)
    set(DirectX_INCLUDE_DIRS "")
    set(DirectX_LIBRARIES dinput8 dsound dxguid xinput xaudio2 x3daudio)

    # Create interface target for modern SDK
    if(NOT TARGET DirectX::DirectX)
        add_library(DirectX::DirectX INTERFACE IMPORTED)
        set_target_properties(DirectX::DirectX PROPERTIES
            INTERFACE_LINK_LIBRARIES "dinput8;dsound;dxguid;xinput;xaudio2;x3daudio"
        )
    endif()

    message(STATUS "Found DirectX: Using Windows SDK (modern)")
else()
    # Traditional setup - need explicit paths
    include(FindPackageHandleStandardArgs)
    find_package_handle_standard_args(DirectX
        REQUIRED_VARS
            DirectX_INCLUDE_DIR
            DirectX_DINPUT8_LIBRARY
            DirectX_DSOUND_LIBRARY
            DirectX_DXGUID_LIBRARY
            DirectX_XINPUT_LIBRARY
    )

    if(DirectX_FOUND)
        set(DirectX_INCLUDE_DIRS "${DirectX_INCLUDE_DIR}")
        set(DirectX_LIBRARIES
            ${DirectX_DINPUT8_LIBRARY}
            ${DirectX_DSOUND_LIBRARY}
            ${DirectX_DXGUID_LIBRARY}
            ${DirectX_XINPUT_LIBRARY}
            xaudio2
            x3daudio
        )

        # Create imported targets
        if(NOT TARGET DirectX::dinput8)
            add_library(DirectX::dinput8 UNKNOWN IMPORTED)
            set_target_properties(DirectX::dinput8 PROPERTIES
                IMPORTED_LOCATION "${DirectX_DINPUT8_LIBRARY}"
                INTERFACE_INCLUDE_DIRECTORIES "${DirectX_INCLUDE_DIR}"
            )
        endif()

        if(NOT TARGET DirectX::dsound)
            add_library(DirectX::dsound UNKNOWN IMPORTED)
            set_target_properties(DirectX::dsound PROPERTIES
                IMPORTED_LOCATION "${DirectX_DSOUND_LIBRARY}"
                INTERFACE_INCLUDE_DIRECTORIES "${DirectX_INCLUDE_DIR}"
            )
        endif()

        if(NOT TARGET DirectX::dxguid)
            add_library(DirectX::dxguid UNKNOWN IMPORTED)
            set_target_properties(DirectX::dxguid PROPERTIES
                IMPORTED_LOCATION "${DirectX_DXGUID_LIBRARY}"
                INTERFACE_INCLUDE_DIRECTORIES "${DirectX_INCLUDE_DIR}"
            )
        endif()

        if(NOT TARGET DirectX::xinput)
            add_library(DirectX::xinput UNKNOWN IMPORTED)
            set_target_properties(DirectX::xinput PROPERTIES
                IMPORTED_LOCATION "${DirectX_XINPUT_LIBRARY}"
                INTERFACE_INCLUDE_DIRECTORIES "${DirectX_INCLUDE_DIR}"
            )
        endif()

        if(NOT TARGET DirectX::DirectX)
            add_library(DirectX::DirectX INTERFACE IMPORTED)
            set_target_properties(DirectX::DirectX PROPERTIES
                INTERFACE_INCLUDE_DIRECTORIES "${DirectX_INCLUDE_DIR}"
                INTERFACE_LINK_LIBRARIES "DirectX::dinput8;DirectX::dsound;DirectX::dxguid;DirectX::xinput"
            )
        endif()
    endif()
endif()

# Mark cache variables as advanced
mark_as_advanced(
    DirectX_INCLUDE_DIR
    DirectX_DINPUT8_LIBRARY
    DirectX_DSOUND_LIBRARY
    DirectX_DXGUID_LIBRARY
    DirectX_XINPUT_LIBRARY
)

# Cleanup internal variables
unset(_DirectX_LIBPATH_SUFFIX)
unset(_DirectX_MODERN_SDK)
unset(_DirectX_HAS_DINPUT_H)
