cmake_minimum_required(VERSION 3.12)
project(Doom3BFG)

set(CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

option(USE_MFC_TOOLS "Compile the built-in MFC based tools" OFF)
option(MONOLITH "Embed game logic into main executable" ON)
option(OPENAL "Use OpenAL soft instead of XAudio2" OFF)
option(FFMPEG "Use FMPEG to render Bink videos" OFF)

if(UNIX)
    set(OPENAL TRUE)
endif()

if(MSVC)
    #message(STATUS CMAKE_ROOT: ${CMAKE_ROOT})

    #if(CMAKE_CL_64)
    #   SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/../bin/win64)
    #else()
    #   SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/../bin/win32)
    #endif()

    #message(STATUS EXECUTABLE_OUTPUT_PATH: ${EXECUTABLE_OUTPUT_PATH})
    #message(STATUS PROJECT_BINARY_DIR: ${PROJECT_BINARY_DIR})
    #message(STATUS CMAKE_BINARY_DIR: ${CMAKE_BINARY_DIR})
else()
    message(STATUS CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE})
endif()

if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_C_COMPILER_ID STREQUAL "Clang")
    add_definitions(-pipe)
    #add_definitions(-Wall)
    add_definitions(-Werror=format-security)
    add_definitions(-Werror=format)
    add_definitions(-mmmx -msse -msse2)
    if(WIN32)
        # require msvcr70.dll or newer for _aligned_malloc etc
        # I think it is from Visual C++ .NET 2002, so it should be available on any remotely modern system.
        add_definitions(-D__MSVCRT_VERSION__=0x0700)
        # Use MinGW's own printf implementation which supports C99 format specifiers (%z, etc.)
        # GCC's compile-time format checker still uses MSVCRT format tables though,
        # so demote format errors to warnings for MinGW builds.
        add_definitions(-D__USE_MINGW_ANSI_STDIO=1)
        add_compile_options(-Wno-error=format -Wno-error=format-extra-args)
        # Statically link the GCC runtime so the exe doesn't need libgcc_s_seh-1.dll / libstdc++-6.dll
        set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static-libgcc -static-libstdc++")

        #find_package(DirectX REQUIRED)
        include_directories(neo/libs/mingw-hacks)
        #include_directories(${DirectX_INCLUDE_DIR})
        add_definitions(-DUSE_XINPUT)
    endif()

    add_definitions(-DUSE_EXCEPTIONS)

    # the warnings are used for every profile anyway, so put them in a variable
    set(my_warn_flags
        "-Wno-pragmas -Wno-unused-variable -Wno-unused-but-set-variable -Wno-switch -Wno-unused-value -Winvalid-pch -Wno-multichar"
    )

    if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_C_COMPILER_ID STREQUAL "Clang")
        # append clang-specific settings for warnings (the second one make sure clang doesn't complain
        # about unknown -W flags, like -Wno-unused-but-set-variable)
        set(my_warn_flags
            "${my_warn_flags} -Wno-local-type-template-args -Wno-unknown-warning-option"
        )
    endif()

    set(CMAKE_C_FLAGS_DEBUG
        "${CMAKE_C_FLAGS_DEBUG} -D_DEBUG -O0 -ggdb -fno-strict-aliasing ${my_warn_flags}"
    )
    set(CMAKE_C_FLAGS_RELEASE
        "${CMAKE_C_FLAGS_RELEASE} -O3 -ffast-math -fno-unsafe-math-optimizations -fomit-frame-pointer -fno-strict-aliasing ${my_warn_flags}"
    )
    set(CMAKE_C_FLAGS_RELWITHDEBINFO
        "${CMAKE_C_FLAGS_RELWITHDEBINFO} -g -O3 -ffast-math -fno-unsafe-math-optimizations -fomit-frame-pointer -fno-strict-aliasing ${my_warn_flags}"
    )
    set(CMAKE_C_FLAGS_MINSIZEREL
        "${CMAKE_C_FLAGS_MINSIZEREL} -Os -ffast-math -fno-unsafe-math-optimizations -fomit-frame-pointer -fno-strict-aliasing ${my_warn_flags}"
    )

    set(CMAKE_CXX_FLAGS_DEBUG ${CMAKE_C_FLAGS_DEBUG})
    set(CMAKE_CXX_FLAGS_RELEASE ${CMAKE_C_FLAGS_RELEASE})
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO ${CMAKE_C_FLAGS_RELWITHDEBINFO})
    set(CMAKE_CXX_FLAGS_MINSIZEREL ${CMAKE_C_FLAGS_MINSIZEREL})
elseif(MSVC)
    # Multiprocessor support for compiling
    # /MP

    # /MT  use multithreaded, static runtime library
    #      (=> binary won't need MSVCP100D.dll or similar)
    # /MTd the same with debug symbols
    # /MD and /MDd - the same with dynamic runtime lib
    #     (=> MSVCP100D.dll or similar is needed to run binary)

    # Inline Function Expansion: Any Suitable (/Ob2)
    # "/Ob2",

    # enable Intrinsic Functions
    # "/Oi",

    # Omit Frame Pointers
    # "/Oy",

    # if(MSVC_VERSION EQUAL 1700)
    # #message(STATUS "$ENV{LIBPATH}")

    # find_path(Windows_winmd_DIR NAMES Windows.winmd
    # HINTS
    # C:/Program Files (x86)/Windows Kits/8.0/References/CommonConfiguration/Neutral
    # PATH_SUFFIXES "Neutral")

    # message(STATUS "${Windows_winmd_DIR}")

    # #set(WINRT_OPTIONS "/ZW /D USE_WINRT /AI \"C:\Program Files (x86)\Windows Kits\8.0\References\CommonConfiguration\Neutral\"")
    # #set(WINRT_OPTIONS "/ZW /D USE_WINRT /AI \"$ENV{LIBPATH}\" ")
    # set(WINRT_OPTIONS "/ZW /D USE_WINRT")

    # set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /D _DEBUG /MP ${WINRT_OPTIONS}")
    # set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MP /Oi /Oy ${WINRT_OPTIONS}")
    # set(CMAKE_C_FLAGS_RELWITHDEBINFO "${CMAKE_C_FLAGS_RELWITHDEBINFO} /MP /Oi ${WINRT_OPTIONS}")
    # set(CMAKE_C_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL} /MP /Oi /Oy ${WINRT_OPTIONS}")

    # set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MP ${WINRT_OPTIONS}")
    # set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MP /Oi /Oy ${WINRT_OPTIONS}")
    # set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} /MP ${WINRT_OPTIONS}")
    # set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL} /MP /Oi /Oy ${WINRT_OPTIONS}")
    # else()
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} /D _DEBUG /MP /MTd")
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MP /Oi /Oy /MT")
    set(CMAKE_C_FLAGS_RELWITHDEBINFO
        "${CMAKE_C_FLAGS_RELWITHDEBINFO} /MP /Oi /MTd"
    )
    set(CMAKE_C_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL} /MP /Oi /Oy /MT")

    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} /MP /MTd")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /MP /Oi /Oy /MT")
    set(CMAKE_CXX_FLAGS_RELWITHDEBINFO
        "${CMAKE_CXX_FLAGS_RELWITHDEBINFO} /MP /MTd"
    )
    set(CMAKE_CXX_FLAGS_MINSIZEREL
        "${CMAKE_CXX_FLAGS_MINSIZEREL} /MP /Oi /Oy /MT"
    )

    # RB: without /SAFESEH:NO we can't link against ffmpeg libs and VS2013 or we have to build our own
    # libs for newer compilers
    set(CMAKE_EXE_LINKER_FLAGS_DEBUG
        "${CMAKE_EXE_LINKER_FLAGS_DEBUG} /SAFESEH:NO"
    )
    set(CMAKE_EXE_LINKER_FLAGS_MINSIZEREL
        "${CMAKE_EXE_LINKER_FLAGS_MINSIZEREL} /SAFESEH:NO"
    )
    set(CMAKE_EXE_LINKER_FLAGS_RELEASE
        "${CMAKE_EXE_LINKER_FLAGS_RELEASE} /SAFESEH:NO"
    )
    set(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO
        "${CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO} /SAFESEH:NO"
    )
    # endif()

    add_definitions(
        -DWIN32
        -D_WINDOWS
        -D_CRT_SECURE_NO_DEPRECATE
        -D_CRT_NONSTDC_NO_DEPRECATE
        -D_CRT_SECURE_NO_WARNINGS
        -D_MBCS
        #-DUSE_OPENAL
        -DUSE_EXCEPTIONS
    )

    if(NOT CMAKE_CL_64)
        add_definitions(-D_USE_32BIT_TIME_T)
    endif()

    if(USE_MFC_TOOLS)
        add_definitions(-D_AFXDLL)

        # 0: Use Standard Windows Libraries
        # 1: Use MFC in a Static Library
        # 2: Use MFC in a Shared DLL
        set(CMAKE_MFC_FLAG 2)
    endif()
endif()

add_subdirectory(neo/idlib)

file(GLOB AAS_INCLUDES neo/aas/*.h)
file(GLOB AAS_SOURCES neo/aas/*.cpp)

file(GLOB_RECURSE CM_INCLUDES neo/cm/*.h)
file(GLOB_RECURSE CM_SOURCES neo/cm/*.cpp)

file(GLOB FRAMEWORK_INCLUDES neo/framework/*.h)
file(GLOB FRAMEWORK_SOURCES neo/framework/*.cpp)

file(GLOB FRAMEWORK_ASYNC_INCLUDES neo/framework/async/*.h)
file(GLOB FRAMEWORK_ASYNC_SOURCES neo/framework/async/*.cpp)

file(GLOB RENDERER_INCLUDES neo/renderer/*.h)
file(GLOB RENDERER_SOURCES neo/renderer/*.cpp)

file(GLOB RENDERER_COLOR_INCLUDES neo/renderer/Color/*.h)
file(GLOB RENDERER_COLOR_SOURCES neo/renderer/Color/*.cpp)
file(GLOB RENDERER_DXT_INCLUDES neo/renderer/DXT/*.h)
file(GLOB RENDERER_DXT_SOURCES neo/renderer/DXT/*.cpp)
file(GLOB RENDERER_JOBS_INCLUDES neo/renderer/jobs/*.h)
file(GLOB RENDERER_JOBS_SOURCES neo/renderer/jobs/*.cpp)
file(
    GLOB RENDERER_JOBS_DYNAMICSHADOWVOLUME_INCLUDES
    neo/renderer/jobs/dynamicshadowvolume/*.h
)
file(
    GLOB RENDERER_JOBS_DYNAMICSHADOWVOLUME_SOURCES
    neo/renderer/jobs/dynamicshadowvolume/*.cpp
)
file(
    GLOB RENDERER_JOBS_PRELIGHTSHADOWVOLUME_INCLUDES
    neo/renderer/jobs/prelightshadowvolume/*.h
)
file(
    GLOB RENDERER_JOBS_PRELIGHTSHADOWVOLUME_SOURCES
    neo/renderer/jobs/prelightshadowvolume/*.cpp
)
file(
    GLOB RENDERER_JOBS_STATICSHADOWVOLUME_INCLUDES
    neo/renderer/jobs/staticshadowvolume/*.h
)
file(
    GLOB RENDERER_JOBS_STATICSHADOWVOLUME_SOURCES
    neo/renderer/jobs/staticshadowvolume/*.cpp
)
file(GLOB RENDERER_OPENGL_INCLUDES neo/renderer/OpenGL/*.h)
file(GLOB RENDERER_OPENGL_SOURCES neo/renderer/OpenGL/*.cpp)

set(JPEG_INCLUDES
    neo/libs/jpeg-6/jchuff.h
    neo/libs/jpeg-6/jconfig.h
    neo/libs/jpeg-6/jdct.h
    neo/libs/jpeg-6/jdhuff.h
    neo/libs/jpeg-6/jerror.h
    neo/libs/jpeg-6/jinclude.h
    neo/libs/jpeg-6/jmemsys.h
    neo/libs/jpeg-6/jmorecfg.h
    neo/libs/jpeg-6/jpegint.h
    neo/libs/jpeg-6/jpeglib.h
    neo/libs/jpeg-6/jversion.h
)

set(JPEG_SOURCES
    neo/libs/jpeg-6/jcapimin.cpp
    neo/libs/jpeg-6/jcapistd.cpp
    neo/libs/jpeg-6/jccoefct.cpp
    neo/libs/jpeg-6/jccolor.cpp
    neo/libs/jpeg-6/jcdctmgr.cpp
    neo/libs/jpeg-6/jchuff.cpp
    neo/libs/jpeg-6/jcinit.cpp
    neo/libs/jpeg-6/jcmainct.cpp
    neo/libs/jpeg-6/jcmarker.cpp
    neo/libs/jpeg-6/jcmaster.cpp
    neo/libs/jpeg-6/jcomapi.cpp
    neo/libs/jpeg-6/jcparam.cpp
    neo/libs/jpeg-6/jcphuff.cpp
    neo/libs/jpeg-6/jcprepct.cpp
    neo/libs/jpeg-6/jcsample.cpp
    neo/libs/jpeg-6/jctrans.cpp
    neo/libs/jpeg-6/jdapimin.cpp
    neo/libs/jpeg-6/jdapistd.cpp
    neo/libs/jpeg-6/jdatadst.cpp
    neo/libs/jpeg-6/jdatasrc.cpp
    neo/libs/jpeg-6/jdcoefct.cpp
    neo/libs/jpeg-6/jdcolor.cpp
    neo/libs/jpeg-6/jddctmgr.cpp
    neo/libs/jpeg-6/jdhuff.cpp
    neo/libs/jpeg-6/jdinput.cpp
    neo/libs/jpeg-6/jdmainct.cpp
    neo/libs/jpeg-6/jdmarker.cpp
    neo/libs/jpeg-6/jdmaster.cpp
    neo/libs/jpeg-6/jdmerge.cpp
    neo/libs/jpeg-6/jdphuff.cpp
    neo/libs/jpeg-6/jdpostct.cpp
    neo/libs/jpeg-6/jdsample.cpp
    neo/libs/jpeg-6/jdtrans.cpp
    neo/libs/jpeg-6/jerror.cpp
    neo/libs/jpeg-6/jfdctflt.cpp
    neo/libs/jpeg-6/jfdctfst.cpp
    neo/libs/jpeg-6/jfdctint.cpp
    neo/libs/jpeg-6/jidctflt.cpp
    neo/libs/jpeg-6/jidctfst.cpp
    neo/libs/jpeg-6/jidctint.cpp
    neo/libs/jpeg-6/jidctred.cpp
    #neo/libs/jpeg-6/jload.cpp
    neo/libs/jpeg-6/jmemmgr.cpp
    neo/libs/jpeg-6/jmemnobs.cpp
    #neo/libs/jpeg-6/jpegtran.cpp
    neo/libs/jpeg-6/jquant1.cpp
    neo/libs/jpeg-6/jquant2.cpp
    neo/libs/jpeg-6/jutils.cpp
)

file(GLOB PNG_INCLUDES neo/libs/png/*.h)
file(GLOB PNG_SOURCES neo/libs/png/*.c)

file(GLOB ZLIB_INCLUDES neo/libs/zlib/*.h)
file(GLOB ZLIB_SOURCES neo/libs/zlib/*.c)

file(GLOB MINIZIP_INCLUDES neo/libs/zlib/minizip/*.h)
file(GLOB MINIZIP_SOURCES neo/libs/zlib/minizip/*.c neo/libs/zlib/minizip/*.cpp)

set(SOUND_INCLUDES
    neo/sound/snd_local.h
    neo/sound/sound.h
    neo/sound/SoundVoice.h
    neo/sound/WaveFile.h
)

set(SOUND_SOURCES
    #neo/sound/snd_cache.cpp
    #neo/sound/snd_decoder.cpp
    #neo/sound/snd_efxfile.cpp
    neo/sound/snd_emitter.cpp
    neo/sound/snd_shader.cpp
    neo/sound/snd_system.cpp
    neo/sound/snd_world.cpp
    neo/sound/SoundVoice.cpp
    neo/sound/WaveFile.cpp
)

set(XAUDIO2_INCLUDES
    neo/sound/XAudio2/XA2_SoundHardware.h
    neo/sound/XAudio2/XA2_SoundSample.h
    neo/sound/XAudio2/XA2_SoundVoice.h
)

set(XAUDIO2_SOURCES
    neo/sound/XAudio2/XA2_SoundHardware.cpp
    neo/sound/XAudio2/XA2_SoundSample.cpp
    neo/sound/XAudio2/XA2_SoundVoice.cpp
)

set(OPENAL_INCLUDES
    neo/sound/OpenAL/AL_SoundHardware.h
    neo/sound/OpenAL/AL_SoundSample.h
    neo/sound/OpenAL/AL_SoundVoice.h
)

set(OPENAL_SOURCES
    neo/sound/OpenAL/AL_SoundHardware.cpp
    neo/sound/OpenAL/AL_SoundSample.cpp
    neo/sound/OpenAL/AL_SoundVoice.cpp
)

set(STUBAUDIO_INCLUDES neo/sound/stub/SoundStub.h)

set(STUBAUDIO_SOURCES neo/sound/stub/SoundSample.cpp)

file(GLOB SYS_INCLUDES neo/sys/*.h)
file(GLOB SYS_SOURCES neo/sys/*.cpp)

file(GLOB UI_INCLUDES neo/ui/*.h)
file(GLOB UI_SOURCES neo/ui/*.cpp)

file(GLOB SWF_INCLUDES neo/swf/*.h)
file(GLOB SWF_SOURCES neo/swf/*.cpp)

set(GAMED3XP_INCLUDES
    neo/d3xp/Achievements.h
    neo/d3xp/Actor.h
    neo/d3xp/AF.h
    neo/d3xp/AFEntity.h
    neo/d3xp/AimAssist.h
    neo/d3xp/BrittleFracture.h
    neo/d3xp/Camera.h
    #neo/d3xp/EndLevel.h
    neo/d3xp/Entity.h
    neo/d3xp/Fx.h
    neo/d3xp/Game.h
    neo/d3xp/GameEdit.h
    neo/d3xp/Game_local.h
    neo/d3xp/Grabber.h
    neo/d3xp/IK.h
    neo/d3xp/Item.h
    neo/d3xp/Leaderboards.h
    neo/d3xp/Light.h
    neo/d3xp/Misc.h
    neo/d3xp/Moveable.h
    neo/d3xp/Mover.h
    neo/d3xp/MultiplayerGame.h
    neo/d3xp/Player.h
    neo/d3xp/PlayerIcon.h
    neo/d3xp/PlayerView.h
    neo/d3xp/PredictedValue.h
    neo/d3xp/Projectile.h
    neo/d3xp/Pvs.h
    neo/d3xp/SecurityCamera.h
    neo/d3xp/SmokeParticles.h
    neo/d3xp/Sound.h
    neo/d3xp/Target.h
    neo/d3xp/Trigger.h
    neo/d3xp/Weapon.h
    neo/d3xp/WorldSpawn.h
)

set(GAMED3XP_SOURCES
    neo/d3xp/Achievements.cpp
    neo/d3xp/Actor.cpp
    neo/d3xp/AF.cpp
    neo/d3xp/AFEntity.cpp
    neo/d3xp/AimAssist.cpp
    neo/d3xp/BrittleFracture.cpp
    neo/d3xp/Camera.cpp
    #neo/d3xp/EndLevel.cpp
    neo/d3xp/Entity.cpp
    neo/d3xp/Fx.cpp
    neo/d3xp/GameEdit.cpp
    neo/d3xp/Game_local.cpp
    neo/d3xp/Game_network.cpp
    neo/d3xp/Grabber.cpp
    neo/d3xp/IK.cpp
    neo/d3xp/Item.cpp
    neo/d3xp/Leaderboards.cpp
    neo/d3xp/Light.cpp
    neo/d3xp/Misc.cpp
    neo/d3xp/Moveable.cpp
    neo/d3xp/Mover.cpp
    neo/d3xp/MultiplayerGame.cpp
    neo/d3xp/Player.cpp
    neo/d3xp/PlayerIcon.cpp
    neo/d3xp/PlayerView.cpp
    neo/d3xp/precompiled.cpp
    neo/d3xp/Projectile.cpp
    neo/d3xp/Pvs.cpp
    neo/d3xp/SecurityCamera.cpp
    neo/d3xp/SmokeParticles.cpp
    neo/d3xp/Sound.cpp
    neo/d3xp/Target.cpp
    neo/d3xp/Trigger.cpp
    neo/d3xp/Weapon.cpp
    neo/d3xp/WorldSpawn.cpp
)

file(GLOB GAMED3XP_AI_INCLUDES neo/d3xp/ai/*.h)
file(GLOB GAMED3XP_AI_SOURCES neo/d3xp/ai/*.cpp)

file(GLOB GAMED3XP_ANIM_INCLUDES neo/d3xp/anim/*.h)
file(GLOB GAMED3XP_ANIM_SOURCES neo/d3xp/anim/*.cpp)

file(GLOB GAMED3XP_GAMESYS_INCLUDES neo/d3xp/gamesys/*.h)
set(GAMED3XP_GAMESYS_SOURCES
    #neo/d3xp/gamesys/Callbacks.cpp
    neo/d3xp/gamesys/Class.cpp
    #neo/d3xp/gamesys/DebugGraph.cpp
    neo/d3xp/gamesys/Event.cpp
    neo/d3xp/gamesys/SaveGame.cpp
    neo/d3xp/gamesys/SysCmds.cpp
    neo/d3xp/gamesys/SysCvar.cpp
    #neo/d3xp/gamesys/TypeInfo.cpp
)

file(GLOB GAMED3XP_MENUS_INCLUDES neo/d3xp/menus/*.h)
file(GLOB GAMED3XP_MENUS_SOURCES neo/d3xp/menus/*.cpp)

file(GLOB GAMED3XP_PHYSICS_INCLUDES neo/d3xp/physics/*.h)
file(GLOB GAMED3XP_PHYSICS_SOURCES neo/d3xp/physics/*.cpp)

file(GLOB GAMED3XP_SCRIPT_INCLUDES neo/d3xp/script/*.h)
file(GLOB GAMED3XP_SCRIPT_SOURCES neo/d3xp/script/*.cpp)

file(GLOB COMPILER_INCLUDES neo/tools/compilers/*.h)

file(GLOB COMPILER_AAS_INCLUDES neo/tools/compilers/aas/*.h)
file(GLOB COMPILER_AAS_SOURCES neo/tools/compilers/aas/*.cpp)

file(GLOB COMPILER_DMAP_INCLUDES neo/tools/compilers/dmap/*.h)
file(GLOB COMPILER_DMAP_SOURCES neo/tools/compilers/dmap/*.cpp)

file(GLOB COMPILER_RENDERBUMP_INCLUDES neo/tools/compilers/renderbump/*.h)
file(GLOB COMPILER_RENDERBUMP_SOURCES neo/tools/compilers/renderbump/*.cpp)

file(GLOB COMPILER_ROQVQ_INCLUDES neo/tools/compilers/roqvq/*.h)
file(GLOB COMPILER_ROQVQ_SOURCES neo/tools/compilers/roqvq/*.cpp)

set(TOOLS_INCLUDES neo/tools/edit_public.h)

file(GLOB TOOLS_COMAFX_INCLUDES neo/tools/comafx/*.h)
file(GLOB TOOLS_COMAFX_SOURCES neo/tools/comafx/*.cpp)

set(TOOLS_COMMON_INCLUDES
    neo/tools/common/ColorButton.h
    neo/tools/common/DialogHelpers.h
    neo/tools/common/MaskEdit.h
    neo/tools/common/OpenFileDialog.h
    neo/tools/common/PropertyGrid.h
    neo/tools/common/RegistryOptions.h
    #neo/tools/common/RenderBumpFlatDialog.h
    neo/tools/common/RollupPanel.h
    neo/tools/common/SpinButton.h
)

set(TOOLS_COMMON_SOURCES
    neo/tools/common/AlphaPopup.cpp
    neo/tools/common/ColorButton.cpp
    neo/tools/common/MaskEdit.cpp
    neo/tools/common/OpenFileDialog.cpp
    neo/tools/common/PropertyGrid.cpp
    neo/tools/common/RegistryOptions.cpp
    #neo/tools/common/RenderBumpFlatDialog.cpp
    neo/tools/common/RollupPanel.cpp
    neo/tools/common/SpinButton.cpp
)

file(GLOB TOOLS_COMMON_PROPTREE_INCLUDES neo/tools/common/PropTree/*.h)
file(GLOB TOOLS_COMMON_PROPTREE_SOURCES neo/tools/common/PropTree/*.cpp)

file(GLOB EDITOR_AF_INCLUDES neo/tools/af/*.h)
file(GLOB EDITOR_AF_SOURCES neo/tools/af/*.cpp)

set(EDITOR_DECL_INCLUDES
    neo/tools/decl/DialogDeclBrowser.h
    neo/tools/decl/DialogDeclEditor.h
    neo/tools/decl/DialogDeclNew.h
)

set(EDITOR_DECL_SOURCES
    neo/tools/decl/DialogDeclBrowser.cpp
    neo/tools/decl/DialogDeclEditor.cpp
    neo/tools/decl/DialogDeclNew.cpp
)

file(GLOB EDITOR_DEBUGGER_INCLUDES neo/tools/debugger/*.h)
file(GLOB EDITOR_DEBUGGER_SOURCES neo/tools/debugger/*.cpp)

file(GLOB EDITOR_GUIED_INCLUDES neo/tools/guied/*.h)
set(EDITOR_GUIED_SOURCES
    neo/tools/guied/GEApp.cpp
    neo/tools/guied/GECheckInDlg.cpp
    neo/tools/guied/GEDeleteModifier.cpp
    neo/tools/guied/GEHideModifier.cpp
    neo/tools/guied/GEInsertModifier.cpp
    neo/tools/guied/GEItemPropsDlg.cpp
    neo/tools/guied/GEItemScriptsDlg.cpp
    neo/tools/guied/GEKeyValueModifier.cpp
    neo/tools/guied/GEModifier.cpp
    neo/tools/guied/GEModifierGroup.cpp
    neo/tools/guied/GEModifierStack.cpp
    neo/tools/guied/GEMoveModifier.cpp
    neo/tools/guied/GENavigator.cpp
    neo/tools/guied/GEOptions.cpp
    neo/tools/guied/GEOptionsDlg.cpp
    neo/tools/guied/GEProperties.cpp
    neo/tools/guied/GEPropertyPage.cpp
    neo/tools/guied/GESelectionMgr.cpp
    neo/tools/guied/GESizeModifier.cpp
    neo/tools/guied/GEStateModifier.cpp
    neo/tools/guied/GEStatusBar.cpp
    neo/tools/guied/GETransformer.cpp
    neo/tools/guied/GEViewer.cpp
    neo/tools/guied/GEWindowWrapper.cpp
    #neo/tools/guied/GEWindowWrapper_stub.cpp
    neo/tools/guied/GEWorkspace.cpp
    neo/tools/guied/GEWorkspaceFile.cpp
    neo/tools/guied/GEZOrderModifier.cpp
    neo/tools/guied/guied.cpp
)

file(GLOB EDITOR_MATERIALEDITOR_INCLUDES neo/tools/materialeditor/*.h)
file(GLOB EDITOR_MATERIALEDITOR_SOURCES neo/tools/materialeditor/*.cpp)

file(GLOB EDITOR_PARTICLE_INCLUDES neo/tools/particle/*.h)
file(GLOB EDITOR_PARTICLE_SOURCES neo/tools/particle/*.cpp)

file(GLOB EDITOR_PDA_INCLUDES neo/tools/pda/*.h)
file(GLOB EDITOR_PDA_SOURCES neo/tools/pda/*.cpp)

file(GLOB EDITOR_RADIANT_INCLUDES neo/tools/radiant/*.h)
file(GLOB EDITOR_RADIANT_SOURCES neo/tools/radiant/*.cpp)

file(GLOB EDITOR_SCRIPT_INCLUDES neo/tools/script/*.h)
file(GLOB EDITOR_SCRIPT_SOURCES neo/tools/script/*.cpp)

file(GLOB EDITOR_SOUND_INCLUDES neo/tools/sound/*.h)
file(GLOB EDITOR_SOUND_SOURCES neo/tools/sound/*.cpp)

file(GLOB DOOMCLASSIC_INCLUDES doomclassic/doom/*.h)
file(GLOB DOOMCLASSIC_SOURCES doomclassic/doom/*.cpp)

set(DOOMCLASSIC_STUBAUDIO_SOURCES doomclassic/doom/i_sound_stub.cpp)
set(DOOMCLASSIC_OPENAL_SOURCES doomclassic/doom/i_sound_openal.cpp)
set(DOOMCLASSIC_XAUDIO2_SOURCES doomclassic/doom/i_sound_win32.cpp)

list(
    REMOVE_ITEM
    DOOMCLASSIC_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/doomclassic/doom/i_sound_stub.cpp
)
list(
    REMOVE_ITEM
    DOOMCLASSIC_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/doomclassic/doom/i_sound_openal.cpp
)
list(
    REMOVE_ITEM
    DOOMCLASSIC_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/doomclassic/doom/i_sound_win32.cpp
)

file(GLOB TIMIDITY_INCLUDES neo/libs/timidity/*.h)
file(GLOB TIMIDITY_SOURCES neo/libs/timidity/*.cpp)

file(GLOB_RECURSE WIN32_INCLUDES neo/sys/win32/*.h)
#file(GLOB_RECURSE WIN32_SOURCES neo/sys/win32/*.cpp)

set(WIN32_SOURCES
    neo/sys/win32/win_glimp.cpp
    neo/sys/win32/win_input.cpp
    neo/sys/win32/win_main.cpp
    neo/sys/win32/win_qgl.cpp
    neo/sys/win32/win_shared.cpp
    neo/sys/win32/win_snd.cpp
    neo/sys/win32/win_syscon.cpp
    neo/sys/win32/win_taskkeyhook.cpp
    neo/sys/win32/win_wndproc.cpp
)

if(WIN32)
    list(APPEND WIN32_SOURCES neo/sys/win32/win_cpu.cpp)
endif()

set(WIN32_RESOURCES
    #neo/win32/rc/res/BEVEL.BMP
    #neo/win32/rc/res/BITMAP2.BMP
    #neo/win32/rc/res/BMP00001.BMP
    #neo/win32/rc/res/BMP0002.BMP
    #neo/win32/rc/res/DEFTEX.WAL
    #neo/win32/rc/res/ENDCAP.BMP
    #neo/win32/rc/res/GetString.htm
    #neo/win32/rc/res/IBEVEL.BMP
    #neo/win32/rc/res/IENDCAP.BMP
    #neo/win32/rc/res/MEFileToolbar.bmp
    #neo/win32/rc/res/MEtoolbar.bmp
    #neo/win32/rc/res/MaterialEditor.ico
    #neo/win32/rc/res/PropTree.rc2
    #neo/win32/rc/res/Q.BMP
    #neo/win32/rc/res/RADIANT3.GIF
    #neo/win32/rc/res/Radiant.ico
    #neo/win32/rc/res/RadiantDoc.ico
    #neo/win32/rc/res/TOOLBAR1.BMP
    #neo/win32/rc/res/TOOLBAR2.BMP
    #neo/win32/rc/res/Toolbar.bmp
    #neo/win32/rc/res/VIEWDEFA.BMP
    #neo/win32/rc/res/VIEWOPPO.BMP
    #neo/win32/rc/res/bmp00002.bmp
    #neo/win32/rc/res/bmp00003.bmp
    #neo/win32/rc/res/bmp00004.bmp
    #neo/win32/rc/res/bmp00005.bmp
    #neo/win32/rc/res/cchsb.bmp
    #neo/win32/rc/res/ccrgb.bmp
    #neo/win32/rc/res/dbg_back.bmp
    #neo/win32/rc/res/dbg_breakpoint.ico
    #neo/win32/rc/res/dbg_current.ico
    #neo/win32/rc/res/dbg_currentline.ico
    #neo/win32/rc/res/dbg_empty.ico
    #neo/win32/rc/res/dbg_open.bmp
    #neo/win32/rc/res/dbg_toolbar.bmp
    neo/sys/win32/rc/res/doom.ico
    #neo/win32/rc/res/fpoint.cur
    #neo/win32/rc/res/fxed_link.ico
    #neo/win32/rc/res/fxed_toolbar.bmp
    #neo/win32/rc/res/fxeditor.ico
    #neo/win32/rc/res/guied.ico
    #neo/win32/rc/res/guied_collapse.ico
    #neo/win32/rc/res/guied_expand.ico
    #neo/win32/rc/res/guied_hand.cur
    #neo/win32/rc/res/guied_nav_visible.ico
    #neo/win32/rc/res/guied_nav_visibledisabled.ico
    #neo/win32/rc/res/guied_scripts.ico
    #neo/win32/rc/res/guied_scripts_white.ico
    #neo/win32/rc/res/guied_viewer_toolbar.bmp
    #neo/win32/rc/res/icon2.ico
    #neo/win32/rc/res/logo_sm3dfx.bmp
    #neo/win32/rc/res/matedtree.bmp
    #neo/win32/rc/res/me_disabled_icon.ico
    #neo/win32/rc/res/me_enabled.ico
    #neo/win32/rc/res/me_off_icon.ico
    #neo/win32/rc/res/me_on_icon.ico
    #neo/win32/rc/res/qe3.ico
    #neo/win32/rc/res/shaderbar.bmp
    #neo/win32/rc/res/shaderdoc.ico
    #neo/win32/rc/res/shaderframe.ico
    #neo/win32/rc/res/spliter.cur
)

#if(USE_MFC_TOOLS)
list(APPEND WIN32_RESOURCES neo/sys/win32/rc/doom.rc)
#else()
#   list(APPEND WIN32_RESOURCES neo/sys/win32/rc/doom_nomfc.rc)
#endif()

file(GLOB POSIX_INCLUDES neo/sys/posix/*.h)
file(GLOB POSIX_SOURCES neo/sys/posix/*.cpp)

file(GLOB COMMON_INCLUDES neo/sys/common/*.h)
file(GLOB COMMON_SOURCES neo/sys/common/*.cpp)

file(GLOB SDL_INCLUDES neo/sys/sdl/*.h)
file(GLOB SDL_SOURCES neo/sys/sdl/*.cpp)

source_group("aas" FILES ${AAS_INCLUDES})
source_group("aas" FILES ${AAS_SOURCES})

source_group("cm" FILES ${CM_INCLUDES})
source_group("cm" FILES ${CM_SOURCES})

source_group("framework" FILES ${FRAMEWORK_INCLUDES})
source_group("framework" FILES ${FRAMEWORK_SOURCES})

source_group("framework\\async" FILES ${FRAMEWORK_ASYNC_INCLUDES})
source_group("framework\\async" FILES ${FRAMEWORK_ASYNC_SOURCES})

source_group("renderer" FILES ${RENDERER_INCLUDES})
source_group("renderer" FILES ${RENDERER_SOURCES})

source_group("renderer\\Color" FILES ${RENDERER_COLOR_INCLUDES})
source_group("renderer\\Color" FILES ${RENDERER_COLOR_SOURCES})

source_group("renderer\\DXT" FILES ${RENDERER_DXT_INCLUDES})
source_group("renderer\\DXT" FILES ${RENDERER_DXT_SOURCES})

source_group("renderer\\jobs" FILES ${RENDERER_JOBS_INCLUDES})
source_group("renderer\\jobs" FILES ${RENDERER_JOBS_SOURCES})

source_group(
    "renderer\\jobs\\dynamicshadowvolume"
    FILES ${RENDERER_JOBS_DYNAMICSHADOWVOLUME_INCLUDES}
)
source_group(
    "renderer\\jobs\\dynamicshadowvolume"
    FILES ${RENDERER_JOBS_DYNAMICSHADOWVOLUME_SOURCES}
)

source_group(
    "renderer\\jobs\\prelightshadowvolume"
    FILES ${RENDERER_JOBS_PRELIGHTSHADOWVOLUME_INCLUDES}
)
source_group(
    "renderer\\jobs\\prelightshadowvolume"
    FILES ${RENDERER_JOBS_PRELIGHTSHADOWVOLUME_SOURCES}
)

source_group(
    "renderer\\jobs\\staticshadowvolume"
    FILES ${RENDERER_JOBS_STATICSHADOWVOLUME_INCLUDES}
)
source_group(
    "renderer\\jobs\\staticshadowvolume"
    FILES ${RENDERER_JOBS_STATICSHADOWVOLUME_SOURCES}
)

source_group("renderer\\OpenGL" FILES ${RENDERER_OPENGL_INCLUDES})
source_group("renderer\\OpenGL" FILES ${RENDERER_OPENGL_SOURCES})

source_group("libs\\irrxml" FILES ${IRRXML_INCLUDES})
source_group("libs\\irrxml" FILES ${IRRXML_SOURCES})

source_group("libs\\jpeg-6" FILES ${JPEG_INCLUDES})
source_group("libs\\jpeg-6" FILES ${JPEG_SOURCES})

source_group("libs\\png" FILES ${PNG_INCLUDES})
source_group("libs\\png" FILES ${PNG_SOURCES})

source_group("libs\\zlib" FILES ${ZLIB_INCLUDES})
source_group("libs\\zlib" FILES ${ZLIB_SOURCES})

source_group("libs\\zlib\\minizip" FILES ${MINIZIP_INCLUDES})
source_group("libs\\zlib\\minizip" FILES ${MINIZIP_SOURCES})

source_group("sound" FILES ${SOUND_INCLUDES})
source_group("sound" FILES ${SOUND_SOURCES})

source_group("sound\\XAudio2" FILES ${XAUDIO2_INCLUDES})
source_group("sound\\XAudio2" FILES ${XAUDIO2_SOURCES})

source_group("sound\\OpenAL" FILES ${OPENAL_INCLUDES})
source_group("sound\\OpenAL" FILES ${OPENAL_SOURCES})

source_group("sound\\stub" FILES ${STUBAUDIO_INCLUDES})
source_group("sound\\stub" FILES ${STUBAUDIO_SOURCES})

source_group("ui" FILES ${UI_INCLUDES})
source_group("ui" FILES ${UI_SOURCES})

source_group("swf" FILES ${SWF_INCLUDES})
source_group("swf" FILES ${SWF_SOURCES})

source_group("sys" FILES ${SYS_INCLUDES})
source_group("sys" FILES ${SYS_SOURCES})

source_group("doomclassic" FILES ${DOOMCLASSIC_INCLUDES})
source_group("doomclassic" FILES ${DOOMCLASSIC_SOURCES})

source_group("doomclassic" FILES ${DOOMCLASSIC_STUBAUDIO_SOURCES})
source_group("doomclassic" FILES ${DOOMCLASSIC_OPENAL_SOURCES})
source_group("doomclassic" FILES ${DOOMCLASSIC_XAUDIO2_SOURCES})

source_group("libs\\timidity" FILES ${TIMIDITY_INCLUDES})
source_group("libs\\timidity" FILES ${TIMIDITY_SOURCES})

source_group("game-d3xp" FILES ${GAMED3XP_INCLUDES})
source_group("game-d3xp" FILES ${GAMED3XP_SOURCES})

source_group("game-d3xp\\ai" FILES ${GAMED3XP_AI_INCLUDES})
source_group("game-d3xp\\ai" FILES ${GAMED3XP_AI_SOURCES})

source_group("game-d3xp\\anim" FILES ${GAMED3XP_ANIM_INCLUDES})
source_group("game-d3xp\\anim" FILES ${GAMED3XP_ANIM_SOURCES})

source_group("game-d3xp\\gamesys" FILES ${GAMED3XP_GAMESYS_INCLUDES})
source_group("game-d3xp\\gamesys" FILES ${GAMED3XP_GAMESYS_SOURCES})

source_group("game-d3xp\\menus" FILES ${GAMED3XP_MENUS_INCLUDES})
source_group("game-d3xp\\menus" FILES ${GAMED3XP_MENUS_SOURCES})

source_group("game-d3xp\\physics" FILES ${GAMED3XP_PHYSICS_INCLUDES})
source_group("game-d3xp\\physics" FILES ${GAMED3XP_PHYSICS_SOURCES})

source_group("game-d3xp\\script" FILES ${GAMED3XP_SCRIPT_INCLUDES})
source_group("game-d3xp\\script" FILES ${GAMED3XP_SCRIPT_SOURCES})

source_group("sys\\win32" FILES ${WIN32_INCLUDES})
source_group("sys\\win32" FILES ${WIN32_SOURCES})
source_group("sys\\win32\\Resources" FILES ${WIN32_RESOURCES})

source_group("sys\\posix" FILES ${POSIX_INCLUDES})
source_group("sys\\posix" FILES ${POSIX_SOURCES})

source_group("sys\\common" FILES ${COMMON_INCLUDES})
source_group("sys\\common" FILES ${COMMON_SOURCES})

source_group("sys\\sdl" FILES ${SDL_INCLUDES})
source_group("sys\\sdl" FILES ${SDL_SOURCES})

source_group("tools\\compilers" FILES ${COMPILER_INCLUDES})

source_group("tools\\compilers\\aas" FILES ${COMPILER_AAS_INCLUDES})
source_group("tools\\compilers\\aas" FILES ${COMPILER_AAS_SOURCES})

source_group("tools\\compilers\\dmap" FILES ${COMPILER_DMAP_INCLUDES})
source_group("tools\\compilers\\dmap" FILES ${COMPILER_DMAP_SOURCES})

source_group(
    "tools\\compilers\\renderbump"
    FILES ${COMPILER_RENDERBUMP_INCLUDES}
)
source_group(
    "tools\\compilers\\renderbump"
    FILES ${COMPILER_RENDERBUMP_SOURCES}
)

source_group("tools\\compilers\\roqvq" FILES ${COMPILER_ROQVQ_INCLUDES})
source_group("tools\\compilers\\roqvq" FILES ${COMPILER_ROQVQ_SOURCES})

source_group("tools" FILES ${TOOLS_INCLUDES})

source_group("tools\\comafx" FILES ${TOOLS_COMAFX_INCLUDES})
source_group("tools\\comafx" FILES ${TOOLS_COMAFX_SOURCES})

source_group("tools\\common" FILES ${TOOLS_COMMON_INCLUDES})
source_group("tools\\common" FILES ${TOOLS_COMMON_SOURCES})

source_group("tools\\common\\proptree" FILES ${TOOLS_COMMON_PROPTREE_INCLUDES})
source_group("tools\\common\\proptree" FILES ${TOOLS_COMMON_PROPTREE_SOURCES})

source_group("tools\\af" FILES ${EDITOR_AF_INCLUDES})
source_group("tools\\af" FILES ${EDITOR_AF_SOURCES})

source_group("tools\\debugger" FILES ${EDITOR_DEBUGGER_INCLUDES})
source_group("tools\\debugger" FILES ${EDITOR_DEBUGGER_SOURCES})

source_group("tools\\decl" FILES ${EDITOR_DECL_INCLUDES})
source_group("tools\\decl" FILES ${EDITOR_DECL_SOURCES})

source_group("tools\\guied" FILES ${EDITOR_GUIED_INCLUDES})
source_group("tools\\guied" FILES ${EDITOR_GUIED_SOURCES})

source_group("tools\\materialeditor" FILES ${EDITOR_MATERIALEDITOR_INCLUDES})
source_group("tools\\materialeditor" FILES ${EDITOR_MATERIALEDITOR_SOURCES})

source_group("tools\\particle" FILES ${EDITOR_PARTICLE_INCLUDES})
source_group("tools\\particle" FILES ${EDITOR_PARTICLE_SOURCES})

source_group("tools\\pda" FILES ${EDITOR_PDA_INCLUDES})
source_group("tools\\pda" FILES ${EDITOR_PDA_SOURCES})

source_group("tools\\radiant" FILES ${EDITOR_RADIANT_INCLUDES})
source_group("tools\\radiant" FILES ${EDITOR_RADIANT_SOURCES})

source_group("tools\\script" FILES ${EDITOR_SCRIPT_INCLUDES})
source_group("tools\\script" FILES ${EDITOR_SCRIPT_SOURCES})

source_group("tools\\sound" FILES ${EDITOR_SOUND_INCLUDES})
source_group("tools\\sound" FILES ${EDITOR_SOUND_SOURCES})

set(DOOM_INCLUDES
    ${AAS_INCLUDES}
    ${CM_INCLUDES}
    ${FRAMEWORK_INCLUDES}
    ${FRAMEWORK_ASYNC_INCLUDES}
    ${RENDERER_INCLUDES}
    ${RENDERER_COLOR_INCLUDES}
    ${RENDERER_DXT_INCLUDES}
    ${RENDERER_JOBS_INCLUDES}
    ${RENDERER_JOBS_DYNAMICSHADOWVOLUME_INCLUDES}
    ${RENDERER_JOBS_PRELIGHTSHADOWVOLUME_INCLUDES}
    ${RENDERER_JOBS_STATICSHADOWVOLUME_INCLUDES}
    ${RENDERER_OPENGL_INCLUDES}
    #${IRRXML_INCLUDES}
    ${JPEG_INCLUDES}
    #${PNG_INCLUDES}
    ${ZLIB_INCLUDES}
    ${MINIZIP_INCLUDES}
    ${SOUND_INCLUDES}
    ${UI_INCLUDES}
    ${SWF_INCLUDES}
    ${COMMON_INCLUDES}
    ${DOOMCLASSIC_INCLUDES}
    ${TIMIDITY_INCLUDES}
    #${COMPILER_INCLUDES}
    #${COMPILER_AAS_INCLUDES} ${COMPILER_AAS_SOURCES}
    #${COMPILER_DMAP_INCLUDES} ${COMPILER_DMAP_SOURCES}
    #${COMPILER_RENDERBUMP_INCLUDES} ${COMPILER_RENDERBUMP_SOURCES}
    #${COMPILER_ROQVQ_INCLUDES} ${COMPILER_ROQVQ_SOURCES}
)

set(DOOM_SOURCES
    ${AAS_SOURCES}
    ${CM_SOURCES}
    ${FRAMEWORK_SOURCES}
    ${FRAMEWORK_ASYNC_SOURCES}
    ${RENDERER_SOURCES}
    ${RENDERER_COLOR_SOURCES}
    ${RENDERER_DXT_SOURCES}
    ${RENDERER_JOBS_SOURCES}
    ${RENDERER_JOBS_DYNAMICSHADOWVOLUME_SOURCES}
    ${RENDERER_JOBS_PRELIGHTSHADOWVOLUME_SOURCES}
    ${RENDERER_JOBS_STATICSHADOWVOLUME_SOURCES}
    ${RENDERER_OPENGL_SOURCES}
    #${IRRXML_SOURCES}
    ${JPEG_SOURCES}
    #${PNG_SOURCES}
    ${ZLIB_SOURCES}
    ${MINIZIP_SOURCES}
    ${SOUND_SOURCES}
    ${UI_SOURCES}
    ${SWF_SOURCES}
    ${COMMON_SOURCES}
    ${DOOMCLASSIC_SOURCES}
    ${TIMIDITY_SOURCES}
    #${COMPILER_AAS_SOURCES}
    #${COMPILER_DMAP_SOURCES}
    #${COMPILER_RENDERBUMP_SOURCES}
    #${COMPILER_ROQVQ_SOURCES}
)

add_definitions(-DUSE_DOOMCLASSIC)

add_definitions(
    -D__DOOM__
)

if(MONOLITH)
    list(
        APPEND
        DOOM_INCLUDES
        ${GAMED3XP_INCLUDES}
        ${GAMED3XP_AI_INCLUDES}
        ${GAMED3XP_ANIM_INCLUDES}
        ${GAMED3XP_GAMESYS_INCLUDES}
        ${GAMED3XP_MENUS_INCLUDES}
        ${GAMED3XP_PHYSICS_INCLUDES}
        ${GAMED3XP_SCRIPT_INCLUDES}
    )

    list(
        APPEND
        DOOM_SOURCES
        ${GAMED3XP_SOURCES}
        ${GAMED3XP_AI_SOURCES}
        ${GAMED3XP_ANIM_SOURCES}
        ${GAMED3XP_GAMESYS_SOURCES}
        ${GAMED3XP_MENUS_SOURCES}
        ${GAMED3XP_PHYSICS_SOURCES}
        ${GAMED3XP_SCRIPT_SOURCES}
    )
else()
    add_definitions(-D__DOOM_DLL__)
endif()

include_directories(
    neo
    neo/idlib
    neo/libs/zlib
)

if(MSVC)
    # if(MSVC_VERSION EQUAL 1700)
    # set(DirectX_LIBRARIES
    # dinput8
    # dsound
    # dxguid
    # #dxerr
    # Xinput
    # xaudio2.lib
    # )

    # if(NOT OPENAL)
    # list(APPEND DirectX_LIBRARIES xaudio2.lib)
    # endif()

    # else()
    find_package(DirectX REQUIRED)
    include_directories(${DirectX_INCLUDE_DIR})
    #endif()

    if(OPENAL)
        add_definitions(-DUSE_OPENAL)

        include_directories(
            ${CMAKE_CURRENT_SOURCE_DIR}/libs/openal-soft/include
        )

        if(CMAKE_CL_64)
            link_directories(
                ${CMAKE_CURRENT_SOURCE_DIR}/libs/openal-soft/lib/win64
            )
        else()
            link_directories(
                ${CMAKE_CURRENT_SOURCE_DIR}/libs/openal-soft/lib/win32
            )
        endif()

        list(APPEND DOOM_INCLUDES ${OPENAL_INCLUDES})
        list(
            APPEND
            DOOM_SOURCES
            ${OPENAL_SOURCES}
            ${DOOMCLASSIC_OPENAL_SOURCES}
        )

        set(OpenAL_LIBRARIES OpenAL32)

        if(CMAKE_CL_64)
            install(FILES neo/libs/openal-soft/lib/win64/OpenAL64.dll DESTINATION .)
        else()
            install(FILES neo/libs/openal-soft/lib/win32/OpenAL32.dll DESTINATION .)
            install(FILES neo/libs/openal-soft/lib/win32/OpenAL32.pdb DESTINATION .)
        endif()
    else()
        list(APPEND DOOM_INCLUDES ${XAUDIO2_INCLUDES})
        list(
            APPEND
            DOOM_SOURCES
            ${XAUDIO2_SOURCES}
            ${DOOMCLASSIC_XAUDIO2_SOURCES}
        )
    endif()

    if(FFMPEG)
        add_definitions(-DUSE_FFMPEG)

        if(CMAKE_CL_64)
            include_directories(neo/libs/ffmpeg-win64/include)
            include_directories(neo/libs/ffmpeg-win64/include/libswscale)
            include_directories(neo/libs/ffmpeg-win64/include/libavformat)
            include_directories(neo/libs/ffmpeg-win64/include/libavdevice)
            include_directories(neo/libs/ffmpeg-win64/include/libavcodec)

            link_directories(${CMAKE_CURRENT_SOURCE_DIR}/neo/libs/ffmpeg-win64/lib)
        else()
            include_directories(neo/libs/ffmpeg-win32/include)
            include_directories(neo/libs/ffmpeg-win32/include/libswscale)
            include_directories(neo/libs/ffmpeg-win32/include/libavformat)
            include_directories(neo/libs/ffmpeg-win32/include/libavdevice)
            include_directories(neo/libs/ffmpeg-win32/include/libavcodec)

            link_directories(${CMAKE_CURRENT_SOURCE_DIR}/neo/libs/ffmpeg-win32/lib)

            set(FFmpeg_LIBRARIES avcodec avformat avutil swscale)
        endif()
    endif()

    if(USE_MFC_TOOLS)
        include_directories(neo/libs/atlmfc/include)
        if(CMAKE_CL_64)
            link_directories(${CMAKE_CURRENT_SOURCE_DIR}/neo/libs/atlmfc/lib/amd64)
        else()
            link_directories(${CMAKE_CURRENT_SOURCE_DIR}/neo/libs/atlmfc/lib)
        endif()

        add_definitions(-DUSE_MFC_TOOLS)

        list(
            APPEND
            DOOM_SOURCES
            ${TOOLS_INCLUDES}
            ${TOOLS_COMAFX_INCLUDES}
            ${TOOLS_COMAFX_SOURCES}
            ${TOOLS_COMMON_INCLUDES}
            ${TOOLS_COMMON_SOURCES}
            ${TOOLS_COMMON_PROPTREE_INCLUDES}
            ${TOOLS_COMMON_PROPTREE_SOURCES}
            ${EDITOR_AF_INCLUDES}
            ${EDITOR_AF_SOURCES}
            ${EDITOR_DEBUGGER_INCLUDES}
            ${EDITOR_DEBUGGER_SOURCES}
            ${EDITOR_DECL_INCLUDES}
            ${EDITOR_DECL_SOURCES}
            ${EDITOR_GUIED_INCLUDES}
            ${EDITOR_GUIED_SOURCES}
            ${EDITOR_MATERIALEDITOR_INCLUDES}
            ${EDITOR_MATERIALEDITOR_SOURCES}
            ${EDITOR_PARTICLE_INCLUDES}
            ${EDITOR_PARTICLE_SOURCES}
            ${EDITOR_PDA_INCLUDES}
            ${EDITOR_PDA_SOURCES}
            ${EDITOR_RADIANT_INCLUDES}
            ${EDITOR_RADIANT_SOURCES}
            ${EDITOR_SCRIPT_INCLUDES}
            ${EDITOR_SCRIPT_SOURCES}
            ${EDITOR_SOUND_INCLUDES}
            ${EDITOR_SOUND_SOURCES}
        )
    endif()

    list(APPEND DOOM_INCLUDES ${SYS_INCLUDES} ${WIN32_INCLUDES})

    list(APPEND DOOM_SOURCES ${SYS_SOURCES} ${WIN32_SOURCES})

    list(REMOVE_DUPLICATES DOOM_SOURCES)

    set(DOOM_PRECOMPILED_SOURCES ${DOOM_SOURCES})
    list(
        REMOVE_ITEM
        DOOM_PRECOMPILED_SOURCES
        ${TIMIDITY_SOURCES}
        ${JPEG_SOURCES}
        ${ZLIB_SOURCES}
    )
    list(
        REMOVE_ITEM
        DOOM_PRECOMPILED_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/neo/libs/zlib/minizip/ioapi.c
    )
    list(
        REMOVE_ITEM
        DOOM_PRECOMPILED_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/neo/renderer/DXT/DXTDecoder.cpp
    )
    list(
        REMOVE_ITEM
        DOOM_PRECOMPILED_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/neo/renderer/DXT/DXTEncoder.cpp
    )
    list(
        REMOVE_ITEM
        DOOM_PRECOMPILED_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/neo/renderer/DXT/DXTEncoder_SSE2.cpp
    )
    list(
        REMOVE_ITEM
        DOOM_PRECOMPILED_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/neo/renderer/jobs/dynamicshadowvolume/DynamicShadowVolume.cpp
    )
    list(
        REMOVE_ITEM
        DOOM_PRECOMPILED_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/neo/renderer/jobs/prelightshadowvolume/PreLightShadowVolume.cpp
    )
    list(
        REMOVE_ITEM
        DOOM_PRECOMPILED_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/neo/renderer/jobs/staticshadowvolume/StaticShadowVolume.cpp
    )
    list(
        REMOVE_ITEM
        DOOM_PRECOMPILED_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/neo/renderer/jobs/ShadowShared.cpp
    )
    list(
        REMOVE_ITEM
        DOOM_PRECOMPILED_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/neo/renderer/RenderLog.cpp
    )

    foreach(src_file ${DOOM_PRECOMPILED_SOURCES})
        #message(STATUS "/Yuprecompiled.h for ${src_file}")
        set_source_files_properties(
            ${src_file}
            PROPERTIES COMPILE_FLAGS "/Yuprecompiled.h"
        )
    endforeach()

    set_source_files_properties(
        neo/framework/precompiled.cpp
        PROPERTIES COMPILE_FLAGS "/Ycprecompiled.h"
    )

    list(APPEND DOOM_SOURCES ${WIN32_RESOURCES})

    add_executable(Doom3BFG WIN32 ${DOOM_INCLUDES} ${DOOM_SOURCES})

    add_dependencies(Doom3BFG idlib)
    target_link_libraries(
        Doom3BFG
        idlib
        ${DirectX_LIBRARIES}
        opengl32
        glu32
        dbghelp
        iphlpapi
        winmm
        wsock32.lib
        ${OpenAL_LIBRARIES}
        ${FFmpeg_LIBRARIES}
    )

    #CMAKE_BINARY_DIR
    if(CMAKE_CL_64)
        install(TARGETS Doom3BFG RUNTIME DESTINATION .)
    else()
        install(TARGETS Doom3BFG RUNTIME DESTINATION .)
    endif()
else()
    list(APPEND DOOM_SOURCES ${SYS_INCLUDES} ${SYS_SOURCES})

    if(WIN32)
        # MinGW cross-compilation for Windows
        set(OPENAL TRUE)

        list(APPEND DOOM_INCLUDES ${SYS_INCLUDES} ${WIN32_INCLUDES})
        list(APPEND DOOM_SOURCES ${WIN32_SOURCES})

        add_definitions(-DUSE_OPENAL)

        include_directories(
            ${CMAKE_CURRENT_SOURCE_DIR}/neo/libs/openal-soft-1.25.1/include
        )
        link_directories(
            ${CMAKE_CURRENT_SOURCE_DIR}/neo/libs/openal-soft-1.25.1/libs/Win64
        )

        list(APPEND DOOM_INCLUDES ${OPENAL_INCLUDES})
        list(
            APPEND
            DOOM_SOURCES
            ${OPENAL_SOURCES}
            ${DOOMCLASSIC_OPENAL_SOURCES}
        )

        set(OpenAL_LIBRARIES OpenAL32)

        # Copy OpenAL DLLs to the build directory so the exe can find them
        set(OPENAL_ROUTER_DLL ${CMAKE_CURRENT_SOURCE_DIR}/neo/libs/openal-soft-1.25.1/router/Win64/OpenAL32.dll)
        set(OPENAL_SOFT_DLL ${CMAKE_CURRENT_SOURCE_DIR}/neo/libs/openal-soft-1.25.1/bin/Win64/soft_oal.dll)
        configure_file(${OPENAL_ROUTER_DLL} ${CMAKE_BINARY_DIR}/OpenAL32.dll COPYONLY)
        configure_file(${OPENAL_SOFT_DLL} ${CMAKE_BINARY_DIR}/soft_oal.dll COPYONLY)

        # Copy base/renderprogs to build directory so the exe can find shader sources
        file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/base/renderprogs
             DESTINATION ${CMAKE_BINARY_DIR}/base)
        # Copy base/default.cfg
        file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/base/default.cfg
             DESTINATION ${CMAKE_BINARY_DIR}/base)
    elseif(UNIX)
        if(FFMPEG)
            find_package(FFmpeg REQUIRED)
            add_definitions(-DUSE_FFMPEG)

            include_directories(${FFMPEG_INCLUDE_DIR})
            link_directories(${FFMPEG_LIBRARIES_DIRS})
        endif()

        find_package(SDL2 REQUIRED)
        include_directories(${SDL2_INCLUDE_DIR})

        list(
            APPEND
            DOOM_SOURCES
            ${POSIX_INCLUDES}
            ${POSIX_SOURCES}
            ${SDL_INCLUDES}
            ${SDL_SOURCES}
            neo/sys/linux/linux_main.cpp
        )

        if(OPENAL)
            find_package(OpenAL REQUIRED)
            add_definitions(-DUSE_OPENAL)

            list(APPEND DOOM_INCLUDES ${OPENAL_INCLUDES})
            list(
                APPEND
                DOOM_SOURCES
                ${OPENAL_SOURCES}
                ${DOOMCLASSIC_OPENAL_SOURCES}
            )
        else()
            list(APPEND DOOM_INCLUDES ${STUBAUDIO_INCLUDES})
            list(
                APPEND
                DOOM_SOURCES
                ${STUBAUDIO_SOURCES}
                ${DOOMCLASSIC_STUBAUDIO_SOURCES}
            )
        endif()
    endif()

    list(REMOVE_DUPLICATES DOOM_SOURCES)

    set(DOOM_PRECOMPILED_SOURCES ${DOOM_SOURCES})
    list(
        REMOVE_ITEM
        DOOM_PRECOMPILED_SOURCES
        ${TIMIDITY_SOURCES}
        ${JPEG_SOURCES}
        ${ZLIB_SOURCES}
    )
    list(
        REMOVE_ITEM
        DOOM_PRECOMPILED_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/neo/libs/zlib/minizip/ioapi.c
    )
    list(
        REMOVE_ITEM
        DOOM_PRECOMPILED_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/neo/renderer/DXT/DXTDecoder.cpp
    )
    list(
        REMOVE_ITEM
        DOOM_PRECOMPILED_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/neo/renderer/DXT/DXTEncoder.cpp
    )
    list(
        REMOVE_ITEM
        DOOM_PRECOMPILED_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/neo/renderer/DXT/DXTEncoder_SSE2.cpp
    )
    list(
        REMOVE_ITEM
        DOOM_PRECOMPILED_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/neo/renderer/jobs/dynamicshadowvolume/DynamicShadowVolume.cpp
    )
    list(
        REMOVE_ITEM
        DOOM_PRECOMPILED_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/neo/renderer/jobs/prelightshadowvolume/PreLightShadowVolume.cpp
    )
    list(
        REMOVE_ITEM
        DOOM_PRECOMPILED_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/neo/renderer/jobs/staticshadowvolume/StaticShadowVolume.cpp
    )
    list(
        REMOVE_ITEM
        DOOM_PRECOMPILED_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/neo/renderer/jobs/ShadowShared.cpp
    )
    list(
        REMOVE_ITEM
        DOOM_PRECOMPILED_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/neo/renderer/RenderLog.cpp
    )

    foreach(src_file ${DOOM_PRECOMPILED_SOURCES})
        #message(STATUS "-include precompiled.h for ${src_file}")
        set_source_files_properties(
            ${src_file}
            PROPERTIES
                COMPILE_FLAGS
                    "-include ${CMAKE_CURRENT_SOURCE_DIR}/neo/idlib/precompiled.h"
        )
    endforeach()

    # precompiled magic for GCC/clang, adapted from https://gist.github.com/573926
    string(TOUPPER "CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE}" _flags_var_name)
    set(_compiler_FLAGS ${${_flags_var_name}})
    get_directory_property(_directory_flags INCLUDE_DIRECTORIES)
    foreach(item ${_directory_flags})
        list(APPEND _compiler_FLAGS " -I${item}")
    endforeach(item)

    get_directory_property(_directory_flags DEFINITIONS)
    list(APPEND _compiler_FLAGS ${_directory_flags})
    separate_arguments(_compiler_FLAGS)

    # we need to recreate the precompiled header for Doom3BFG
    # (i.e. can't use the one created for idlib before)
    # because some definitions (e.g. -D__IDLIB__ -D__DOOM_DLL__) differ
    add_custom_target(
        precomp_header_rbdoom3bfg
        ALL
        COMMAND
            ${CMAKE_CXX_COMPILER} ${_compiler_FLAGS} -x c++-header
            neo/idlib/precompiled.h -o neo/idlib/precompiled.h.gch
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "Creating idlib/precompiled.h.gch for Doom3BFG"
    )

    # it's ugly enough that the precompiled header binary needs to be in the
    # source directory (instead of the build directory), so let's at least
    # delete it after build.
    add_custom_target(
        rm_precomp_header
        ALL
        COMMAND ${CMAKE_COMMAND} -E remove "neo/idlib/precompiled.h.gch"
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        COMMENT "remove idlib/precompiled.h.gch"
    )

    # make sure this is run after creating idlib
    add_dependencies(precomp_header_rbdoom3bfg idlib)

    add_executable(Doom3BFG WIN32 ${DOOM_SOURCES})

    # make sure precompiled header is created before executable is compiled
    add_dependencies(Doom3BFG precomp_header_rbdoom3bfg)

    # make sure precompiled header is deleted after executable is compiled
    add_dependencies(rm_precomp_header Doom3BFG)

    if("${CMAKE_SYSTEM}" MATCHES "Windows")
        target_link_libraries(
            Doom3BFG
            idlib
            opengl32
            glu32
            dinput8
            dsound
            dxguid
            xinput1_4
            dbghelp
            iphlpapi
            winmm
            wsock32
            imm32
            ole32
            ${OpenAL_LIBRARIES}
            ${FFmpeg_LIBRARIES}
        )
    endif()

    if("${CMAKE_SYSTEM}" MATCHES "Linux")
        target_link_libraries(
            Doom3BFG
            idlib
            GL
            pthread
            dl
            rt
            SDL2::SDL2
            ${OPENAL_LIBRARY}
            ${FFMPEG_LIBRARIES}
        )
    endif()

    if("${CMAKE_SYSTEM}" MATCHES "FreeBSD")
        target_link_libraries(
            Doom3BFG
            idlib
            GL
            pthread
            rt
            SDL2::SDL2
            ${OPENAL_LIBRARY}
            ${FFMPEG_LIBRARIES}
        )
    endif()
endif()
