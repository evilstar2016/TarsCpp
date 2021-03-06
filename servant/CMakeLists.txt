cmake_minimum_required(VERSION 3.2)

project(servant)

if(_USE_OPENTRACKING)
include_directories(${util_SOURCE_DIR}/include ${OPENTRACKING_INC})
else()
include_directories(${util_SOURCE_DIR}/include)
endif()

#调用tars2cpp, 生成tars对应的文件
macro(complice_tars OUT_DEPENDS_LIST HEADER TARS_DIR)
    set(DEPENDS_LIST)

    if ("${TARS_DIR}" STREQUAL "")
        FILE(GLOB SRC_LIST "${CMAKE_CURRENT_SOURCE_DIR}/*.tars")
    else ()
        FILE(GLOB SRC_LIST "${TARS_DIR}/*.tars")
    endif ()

    set(CLEAN_LIST)

    #设置tars生成后, cpp文件因为h文件的include路径
    set(INCLUDE)
    if (NOT "${HEADER}" STREQUAL "")
        set(INCLUDE "--header=${HEADER}")
    endif ()

    foreach (FILE ${SRC_LIST})

        get_filename_component(NAME_WE ${FILE} NAME_WE)

        # 生成tars文件
        set(TARS_IN ${FILE})
        set(TARS_H ${NAME_WE}.h)

        add_custom_command(
                OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/${TARS_H}
                WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
                DEPENDS tars2cpp ${TARS_IN}
                COMMAND ${TARS2CPP} --with-tars ${INCLUDE} ${TARS_IN}
                COMMENT "${TARS2CPP} --with-tars ${INCLUDE} ${TARS_IN}")

        list(APPEND DEPENDS_LIST ${CMAKE_CURRENT_SOURCE_DIR}/${TARS_H})

        #设置需要清除的文件
        get_filename_component(PATH ${FILE} PATH)
        list(APPEND CLEAN_LIST ${PATH}/${NAME_WE}.h)
        if (EXISTS ${PATH}/${NAME_WE}.cpp)
            list(APPEND CLEAN_LIST ${PATH}/${NAME_WE}.cpp)
        endif (EXISTS ${PATH}/${NAME_WE}.cpp)

    endforeach (FILE)

    set(OUT_DEPENDS_LIST ${DEPENDS_LIST})

    set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES "${CLEAN_LIST}")

endmacro()

add_subdirectory(protocol/servant)
add_subdirectory(tup)
add_subdirectory(libservant)

install(DIRECTORY servant DESTINATION include)
install(DIRECTORY tup DESTINATION include)
install(DIRECTORY jmem DESTINATION include)
install(DIRECTORY script DESTINATION .
        PATTERN "*.sh"
        PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ GROUP_EXECUTE GROUP_READ)
install(DIRECTORY makefile DESTINATION .)

