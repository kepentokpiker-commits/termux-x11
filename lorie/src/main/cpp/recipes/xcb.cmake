set(XCB_GEN_DIR "${CMAKE_CURRENT_BINARY_DIR}/xcbgen")
file(MAKE_DIRECTORY "${XCB_GEN_DIR}")

set(XCB_EXTS xproto bigreq xc_misc sync render shape xfixes randr dri3 present)
set(XCB_GEN_SOURCES)
foreach (ext ${XCB_EXTS})
    add_custom_command(
            OUTPUT "${XCB_GEN_DIR}/${ext}.c" "${XCB_GEN_DIR}/${ext}.h"
            COMMAND ${Python3_EXECUTABLE} "${CMAKE_CURRENT_SOURCE_DIR}/libxcb/src/c_client.py"
                    -c xcb -l man -s 3 -p "${CMAKE_CURRENT_SOURCE_DIR}/xcbproto"
                    "${CMAKE_CURRENT_SOURCE_DIR}/xcbproto/src/${ext}.xml"
            WORKING_DIRECTORY "${XCB_GEN_DIR}"
            DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/xcbproto/src/${ext}.xml"
                    "${CMAKE_CURRENT_SOURCE_DIR}/libxcb/src/c_client.py")
    list(APPEND XCB_GEN_SOURCES "${XCB_GEN_DIR}/${ext}.c")
endforeach ()

add_library(xcb STATIC
        "libxcb/src/xcb_conn.c" "libxcb/src/xcb_out.c" "libxcb/src/xcb_in.c" "libxcb/src/xcb_ext.c"
        "libxcb/src/xcb_xid.c" "libxcb/src/xcb_list.c" "libxcb/src/xcb_util.c" "libxcb/src/xcb_auth.c"
        ${XCB_GEN_SOURCES})
target_include_directories(xcb PUBLIC "libxcb/src" "${XCB_GEN_DIR}")
target_compile_options(xcb PRIVATE "-D_GNU_SOURCE=1" "-DUSE_POLL=1" "-DHAVE_SENDMSG=1"
        "-DHAVE_GETADDRINFO=1" "-DHAVE_ABSTRACT_SOCKETS=1" "-DXCB_QUEUE_BUFFER_SIZE=16384" "-fPIC")
