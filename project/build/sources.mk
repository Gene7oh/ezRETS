########################################################################
#
# common
#

COMMON_INC_DIR = project/common/include
COMMON_SRC_DIR = project/common/src
COMMON_OBJ_DIR = build/common/objects
COMMON_SRC_FILES := $(wildcard ${COMMON_SRC_DIR}/*.cpp)
COMMON_OBJECTS	:= $(patsubst $(COMMON_SRC_DIR)/%.cpp, \
	$(COMMON_OBJ_DIR)/%.o, $(COMMON_SRC_FILES))
COMMON_DEPENDS	:= $(patsubst $(COMMON_SRC_DIR)/%.cpp, \
	$(COMMON_OBJ_DIR)/%.d, $(COMMON_SRC_FILES))
COMMON_LIB	= build/common/lib/ezrets-common.a
COMMON_CFLAGS = $(CFLAGS) $(LIBRETS_CFLAGS) -I$(COMMON_INC_DIR) -I$(COMMON_INC_DIR)

$(COMMON_OBJ_DIR)/%.o: $(COMMON_SRC_DIR)/%.cpp
	$(CXX) $(COMMON_CFLAGS) -fPIC -fpic -c $< -o $@

$(COMMON_OBJ_DIR)/%.d: $(COMMON_SRC_DIR)/%.cpp
	@echo Generating dependencies for $<
	@mkdir -p $(dir $@)
	@$(CXX) -MM $(COMMON_CFLAGS) $< \
	| $(FIXDEP) $(COMMON_SRC_DIR) $(COMMON_OBJ_DIR) > $@

$(COMMON_LIB): $(COMMON_OBJECTS)
	$(AR) -rs $(COMMON_LIB) $(COMMON_OBJECTS)


########################################################################
#
# driver
#

DRIVER_SRC_DIR = project/driver/src
DRIVER_INC_DIR = project/driver/include
DRIVER_OBJ_DIR = build/driver/objects
DRIVER_SRC_FILES := $(wildcard ${DRIVER_SRC_DIR}/*.cpp)
DRIVER_OBJECTS	:= $(patsubst $(DRIVER_SRC_DIR)/%.cpp, \
	$(DRIVER_OBJ_DIR)/%.o, $(DRIVER_SRC_FILES))
DRIVER_DEPENDS	:= $(patsubst $(DRIVER_SRC_DIR)/%.cpp, \
	$(DRIVER_OBJ_DIR)/%.d, $(DRIVER_SRC_FILES))
DRIVER_LIB	= build/driver/lib/ezrets.so
DRIVER_CFLAGS = $(CFLAGS) $(LIBRETS_CFLAGS) -I$(COMMON_INC_DIR) -I$(DRIVER_INC_DIR)

$(DRIVER_OBJ_DIR)/%.o: $(DRIVER_SRC_DIR)/%.cpp
	$(CXX) $(DRIVER_CFLAGS) -fPIC -fpic -c $< -o $@

$(DRIVER_OBJ_DIR)/%.d: $(DRIVER_SRC_DIR)/%.cpp
	@echo Generating dependencies for $<
	@mkdir -p $(dir $@)
	@$(CXX) -MM $(DRIVER_CFLAGS) $< \
	| $(FIXDEP) $(DRIVER_SRC_DIR) $(DRIVER_OBJ_DIR) > $@

$(DRIVER_LIB): $(COMMON_LIB) $(DRIVER_OBJECTS)
	$(CXX) -shared -fPIC -fpic $(DRIVER_OBJECTS) -Wl,--whole-archive $(STATIC_LIBS) $(COMMON_LIB) -Wl,--no-whole-archive -Wl,-soname  -Wl,ezrets.so -o $(DRIVER_LIB) -lodbcinst $(LIBRETS_LDFLAGS)



########################################################################
#
# examples
#

EXAMPLES_SRC_DIR = project/examples/cpp/src
EXAMPLES_INC_DIR = project/examples/cpp/include
EXAMPLES_OBJ_DIR = build/examples/objects

EXAMPLES_COMMON_SRC = ${EXAMPLES_SRC_DIR}/DBHelper.cpp \
	              ${EXAMPLES_SRC_DIR}/DBHelperException.cpp \
		      ${EXAMPLES_SRC_DIR}/ResultColumn.cpp

CONTEST_EXAMPLE_SRC_FILES := $(EXAMPLES_COMMON_SRC) ${EXAMPLES_SRC_DIR}/ConnectTest.cpp
CONTEST_EXAMPLE_OBJECTS    := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.o, $(CONTEST_EXAMPLE_SRC_FILES))
CONTEST_EXAMPLE_DEPENDS    := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.d, $(CONTEST_EXAMPLE_SRC_FILES))
CONTEST_EXE = build/examples/bin/ConnectTest

SIMPLESEARCH_EXAMPLE_SRC_FILES := $(EXAMPLES_COMMON_SRC) ${EXAMPLES_SRC_DIR}/SimpleSearch.cpp
SIMPLESEARCH_EXAMPLE_OBJECTS    := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.o, $(SIMPLESEARCH_EXAMPLE_SRC_FILES))
SIMPLESEARCH_EXAMPLE_DEPENDS    := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.d, $(SIMPLESEARCH_EXAMPLE_SRC_FILES))
SIMPLESEARCH_EXE = build/examples/bin/SimpleSearch

NOWHERESEARCH_EXAMPLE_SRC_FILES := $(EXAMPLES_COMMON_SRC) ${EXAMPLES_SRC_DIR}/NoWhereSearch.cpp
NOWHERESEARCH_EXAMPLE_OBJECTS    := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.o, $(NOWHERESEARCH_EXAMPLE_SRC_FILES))
NOWHERESEARCH_EXAMPLE_DEPENDS    := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.d, $(NOWHERESEARCH_EXAMPLE_SRC_FILES))
NOWHERESEARCH_EXE = build/examples/bin/NoWhereSearch

TABLESTEST_EXAMPLE_SRC_FILES := $(EXAMPLES_COMMON_SRC) ${EXAMPLES_SRC_DIR}/TablesTest.cpp
TABLESTEST_EXAMPLE_OBJECTS    := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.o, $(TABLESTEST_EXAMPLE_SRC_FILES))
TABLESTEST_EXAMPLE_DEPENDS    := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.d, $(TABLESTEST_EXAMPLE_SRC_FILES))
TABLESTEST_EXE = build/examples/bin/TablesTest

COLUMNSTEST_EXAMPLE_SRC_FILES := $(EXAMPLES_COMMON_SRC) ${EXAMPLES_SRC_DIR}/ColumnsTest.cpp
COLUMNSTEST_EXAMPLE_OBJECTS    := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.o, $(COLUMNSTEST_EXAMPLE_SRC_FILES))
COLUMNSTEST_EXAMPLE_DEPENDS    := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.d, $(COLUMNSTEST_EXAMPLE_SRC_FILES))
COLUMNSTEST_EXE = build/examples/bin/ColumnsTest

FORCEDERROR_EXAMPLE_SRC_FILES := $(EXAMPLES_COMMON_SRC) ${EXAMPLES_SRC_DIR}/ForcedError.cpp
FORCEDERROR_EXAMPLE_OBJECTS    := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.o, $(FORCEDERROR_EXAMPLE_SRC_FILES))
FORCEDERROR_EXAMPLE_DEPENDS    := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.d, $(FORCEDERROR_EXAMPLE_SRC_FILES))
FORCEDERROR_EXE = build/examples/bin/ForcedError

FLOATERROR_EXAMPLE_SRC_FILES := $(EXAMPLES_COMMON_SRC) ${EXAMPLES_SRC_DIR}/FloatError.cpp
FLOATERROR_EXAMPLE_OBJECTS    := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.o, $(FLOATERROR_EXAMPLE_SRC_FILES))
FLOATERROR_EXAMPLE_DEPENDS    := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.d, $(FLOATERROR_EXAMPLE_SRC_FILES))
FLOATERROR_EXE = build/examples/bin/FloatError

DRIVCONTEST_EXAMPLE_SRC_FILES := $(EXAMPLES_COMMON_SRC) ${EXAMPLES_SRC_DIR}/SQLDriverConnectTest.cpp
DRIVCONTEST_EXAMPLE_OBJECTS    := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.o, $(DRIVCONTEST_EXAMPLE_SRC_FILES))
DRIVCONTEST_EXAMPLE_DEPENDS    := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.d, $(DRIVCONTEST_EXAMPLE_SRC_FILES))
DRIVCONTEST_EXE = build/examples/bin/SQLDriverConnectTest

SIMPLEGETDATA_EXAMPLE_SRC_FILES := $(EXAMPLES_COMMON_SRC) ${EXAMPLES_SRC_DIR}/SimpleGetData.cpp
SIMPLEGETDATA_EXAMPLE_OBJECTS    := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.o, $(SIMPLEGETDATA_EXAMPLE_SRC_FILES))
SIMPLEGETDATA_EXAMPLE_DEPENDS    := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
	$(EXAMPLES_OBJ_DIR)/%.d, $(SIMPLEGETDATA_EXAMPLE_SRC_FILES))
SIMPLEGETDATA_EXE = build/examples/bin/SimpleGetData

PRIMARYKEYS_EXAMPLE_SRC_FILES := $(EXAMPLES_COMMON_SRC) \
				 ${EXAMPLES_SRC_DIR}/PrimaryKeys.cpp
PRIMARYKEYS_EXAMPLE_OBJECTS := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
		$(EXAMPLES_OBJ_DIR)/%.o, $(PRIMARYKEYS_EXAMPLE_SRC_FILES))
PRIMARYKEYS_EXAMPLE_DEPENDS    := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
		$(EXAMPLES_OBJ_DIR)/%.d, $(PRIMARYKEYS_EXAMPLE_SRC_FILES))
PRIMARYKEYS_EXE = build/examples/bin/PrimaryKeys

ADODEBUG_EXAMPLE_SRC_FILES := $(EXAMPLES_COMMON_SRC) \
				 ${EXAMPLES_SRC_DIR}/ADODebug.cpp
ADODEBUG_EXAMPLE_OBJECTS := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
		$(EXAMPLES_OBJ_DIR)/%.o, $(ADODEBUG_EXAMPLE_SRC_FILES))
ADODEBUG_EXAMPLE_DEPENDS    := $(patsubst $(EXAMPLES_SRC_DIR)/%.cpp, \
		$(EXAMPLES_OBJ_DIR)/%.d, $(ADODEBUG_EXAMPLE_SRC_FILES))
ADODEBUG_EXE = build/examples/bin/ADODebug

EXAMPLES_DEPENDS = $(CONTEST_EXAMPLE_DEPENDS) $(SIMPLESEARCH_EXAMPLE_DEPENDS) $(NOWHERESEARCH_EXAMPLE_DEPENDS) $(DRIVCONTEST_DEPENDS) $(FORCEDERROR_EXAMPLE_DEPENDS) $(TABLESTEST_EXAMPLE_DEPENDS) $(COLUMNSTEST_EXAMPLE_DEPENDS) $(FLOATERROR_DEPENDS) $(SIMPLEGETDATA_EXAMPLE_DEPENDS) $(PRIMARYKEYS_EXAMPLES_DEPENDS) $(ADODEBUG_EXAMPLE_DEPENDS)
EXAMPLES_EXE = $(CONTEST_EXE) $(SIMPLESEARCH_EXE) $(NOWHERESEARCH_EXE) $(DRIVCONTEST_EXE) $(FORCEDERROR_EXE) $(TABLESTEST_EXE) $(COLUMNSTEST_EXE) $(FLOATERROR_EXE) $(SIMPLEGETDATA_EXE) $(PRIMARYKEYS_EXE) $(ADODEBUG_EXE)

$(EXAMPLES_OBJ_DIR)/%.o: $(EXAMPLES_SRC_DIR)/%.cpp
	$(CXX) $(CFLAGS) -I$(EXAMPLES_INC_DIR) -c $< -o $@

$(EXAMPLES_OBJ_DIR)/%.d: $(EXAMPLES_SRC_DIR)/%.cpp
	@echo Generating dependencies for $<
	@mkdir -p $(dir $@)
	@$(CC) -MM $(CFLAGS) -I$(DRIVER_INC_DIR) -I$(EXAMPLES_INC_DIR) $< \
	| $(FIXDEP) $(EXAMPLES_SRC_DIR) $(EXAMPLES_OBJ_DIR) > $@

$(CONTEST_EXE): $(CONTEST_EXAMPLE_OBJECTS)
	$(CXX) -o $(CONTEST_EXE) $(CONTEST_EXAMPLE_OBJECTS) -lodbc

$(SIMPLESEARCH_EXE): $(SIMPLESEARCH_EXAMPLE_OBJECTS)
	$(CXX) -o $(SIMPLESEARCH_EXE) $(SIMPLESEARCH_EXAMPLE_OBJECTS) -lodbc

$(NOWHERESEARCH_EXE): $(NOWHERESEARCH_EXAMPLE_OBJECTS)
	$(CXX) -o $(NOWHERESEARCH_EXE) $(NOWHERESEARCH_EXAMPLE_OBJECTS) -lodbc

$(TABLESTEST_EXE): $(TABLESTEST_EXAMPLE_OBJECTS)
	$(CXX) -o $(TABLESTEST_EXE) $(TABLESTEST_EXAMPLE_OBJECTS) -lodbc

$(COLUMNSTEST_EXE): $(COLUMNSTEST_EXAMPLE_OBJECTS)
	$(CXX) -o $(COLUMNSTEST_EXE) $(COLUMNSTEST_EXAMPLE_OBJECTS) -lodbc

$(FORCEDERROR_EXE): $(FORCEDERROR_EXAMPLE_OBJECTS)
	$(CXX) -o $(FORCEDERROR_EXE) $(FORCEDERROR_EXAMPLE_OBJECTS) -lodbc

$(FLOATERROR_EXE): $(FLOATERROR_EXAMPLE_OBJECTS)
	$(CXX) -o $(FLOATERROR_EXE) $(FLOATERROR_EXAMPLE_OBJECTS) -lodbc

$(DRIVCONTEST_EXE): $(DRIVCONTEST_EXAMPLE_OBJECTS)
	$(CXX) -o $(DRIVCONTEST_EXE) $(DRIVCONTEST_EXAMPLE_OBJECTS) -lodbc

$(SIMPLEGETDATA_EXE): $(SIMPLEGETDATA_EXAMPLE_OBJECTS)
	$(CXX) -o $(SIMPLEGETDATA_EXE) $(SIMPLEGETDATA_EXAMPLE_OBJECTS) -lodbc

$(PRIMARYKEYS_EXE): $(PRIMARYKEYS_EXAMPLE_OBJECTS)
	$(CXX) -o $(PRIMARYKEYS_EXE) $(PRIMARYKEYS_EXAMPLE_OBJECTS) -lodbc

$(ADODEBUG_EXE): $(ADODEBUG_EXAMPLE_OBJECTS)
	$(CXX) -o $(ADODEBUG_EXE) $(ADODEBUG_EXAMPLE_OBJECTS) -lodbc

########################################################################
#
# setup
#

SETUP_SRC_DIR = project/setup/src
SETUP_INC_DIR = project/setup/include
SETUP_OBJ_DIR = build/setup/objects
SETUP_SRC_FILES := $(wildcard ${SETUP_SRC_DIR}/*.cpp)
SETUP_OBJECTS	:= $(patsubst $(SETUP_SRC_DIR)/%.cpp, \
	$(SETUP_OBJ_DIR)/%.o, $(SETUP_SRC_FILES))
SETUP_DEPENDS	:= $(patsubst $(SETUP_SRC_DIR)/%.cpp, \
	$(SETUP_OBJ_DIR)/%.d, $(SETUP_SRC_FILES))
SETUP_LIB	= build/setup/lib/ezretss.so
SETUP_CFLAGS = $(CFLAGS) $(LIBRETS_CFLAGS) -I$(COMMON_INC_DIR) -I$(SETUP_INC_DIR) `wx-config --cflags` -fms-extensions

$(SETUP_OBJ_DIR)/%.o: $(SETUP_SRC_DIR)/%.cpp
	$(CXX) $(SETUP_CFLAGS) -fPIC -fpic -c $< -o $@

$(SETUP_OBJ_DIR)/%.d: $(SETUP_SRC_DIR)/%.cpp
	@echo Generating dependencies for $<
	@mkdir -p $(dir $@)
	@$(CXX) -MM $(SETUP_CFLAGS) $< \
	| $(FIXDEP) $(SETUP_SRC_DIR) $(SETUP_OBJ_DIR) > $@

$(SETUP_LIB): $(COMMON_LIB) $(SETUP_OBJECTS)
	$(CXX) -shared -fPIC -fpic $(SETUP_OBJECTS) -Wl,--whole-archive $(STATIC_LIBS) $(COMMON_LIB) -Wl,--no-whole-archive -Wl,-soname  -Wl,ezrets.so -o $(SETUP_LIB) -lodbcinst $(LIBRETS_LDFLAGS) `wx-config --libs`

# g++ -o dude build/setup/objects/ConfigDSN.o
# build/setup/objects/DataSourceValidator.o
# build/setup/objects/DllMain.o build/setup/objects/Setup.o
# build/setup/objects/SetupDialog.o build/setup/objects/SetupLog.o
# build/setup/objects/SqlInstallerException.o
# build/setup/objects/TextValueSizer.o build/setup/objects/testApp.o
# build/common/lib/ezrets-common.a -lodbcinst
# /home/kgarner/src/odbcrets/librets/build/librets/lib/librets.a
# /usr/lib/libboost_filesystem.a
# /usr/local/encap/curl-7.14.1/lib/libcurl.a -L/usr/kerberos/lib -lidn
# -lssl -lcrypto -ldl -lssl -lcrypto -lgssapi_krb5 -lkrb5 -lcom_err
# -lk5crypto -lresolv -ldl -lz -lz /usr/lib/libexpat.a -lantlr
# `wx-config --libs`

########################################################################
#
# misc
#

DISTCLEAN_FILES = \
	config.status config.log config.cache \
	project/driver/src/config.h \
	project/build/Doxyfile
