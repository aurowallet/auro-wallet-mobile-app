cmake_minimum_required(VERSION 3.4.1)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=gnu99 -shared")
file (GLOB MINA_SOURCES "../../ios/Classes/signer/*.c")
file (GLOB MINA_HEADERS "../../ios/Classes/signer/*.h")

add_library( mina_sdk

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             ${MINA_HEADERS}
             ${MINA_SOURCES}
             ../../ios/Classes/portable_endian.h
             ../../ios/Classes/mina_sdk.c
             )
