# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 4.0

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/derrick/.config/emacs/elpaca/builds/vterm

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/derrick/.config/emacs/elpaca/builds/vterm/build

# Utility rule file for libvterm.

# Include any custom commands dependencies for this target.
include CMakeFiles/libvterm.dir/compiler_depend.make

# Include the progress variables for this target.
include CMakeFiles/libvterm.dir/progress.make

CMakeFiles/libvterm: CMakeFiles/libvterm-complete

CMakeFiles/libvterm-complete: libvterm-prefix/src/libvterm-stamp/libvterm-install
CMakeFiles/libvterm-complete: libvterm-prefix/src/libvterm-stamp/libvterm-mkdir
CMakeFiles/libvterm-complete: libvterm-prefix/src/libvterm-stamp/libvterm-download
CMakeFiles/libvterm-complete: libvterm-prefix/src/libvterm-stamp/libvterm-update
CMakeFiles/libvterm-complete: libvterm-prefix/src/libvterm-stamp/libvterm-patch
CMakeFiles/libvterm-complete: libvterm-prefix/src/libvterm-stamp/libvterm-configure
CMakeFiles/libvterm-complete: libvterm-prefix/src/libvterm-stamp/libvterm-build
CMakeFiles/libvterm-complete: libvterm-prefix/src/libvterm-stamp/libvterm-install
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --blue --bold --progress-dir=/home/derrick/.config/emacs/elpaca/builds/vterm/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Completed 'libvterm'"
	/usr/bin/cmake -E make_directory /home/derrick/.config/emacs/elpaca/builds/vterm/build/CMakeFiles
	/usr/bin/cmake -E touch /home/derrick/.config/emacs/elpaca/builds/vterm/build/CMakeFiles/libvterm-complete
	/usr/bin/cmake -E touch /home/derrick/.config/emacs/elpaca/builds/vterm/build/libvterm-prefix/src/libvterm-stamp/libvterm-done

libvterm-prefix/src/libvterm-stamp/libvterm-build: libvterm-prefix/src/libvterm-stamp/libvterm-configure
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --blue --bold --progress-dir=/home/derrick/.config/emacs/elpaca/builds/vterm/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Performing build step for 'libvterm'"
	cd /home/derrick/.config/emacs/elpaca/builds/vterm/build/libvterm-prefix/src/libvterm && make "CFLAGS='-fPIC'" "LDFLAGS='-static'"
	cd /home/derrick/.config/emacs/elpaca/builds/vterm/build/libvterm-prefix/src/libvterm && /usr/bin/cmake -E touch /home/derrick/.config/emacs/elpaca/builds/vterm/build/libvterm-prefix/src/libvterm-stamp/libvterm-build

libvterm-prefix/src/libvterm-stamp/libvterm-configure: libvterm-prefix/tmp/libvterm-cfgcmd.txt
libvterm-prefix/src/libvterm-stamp/libvterm-configure: libvterm-prefix/src/libvterm-stamp/libvterm-patch
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --blue --bold --progress-dir=/home/derrick/.config/emacs/elpaca/builds/vterm/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_3) "No configure step for 'libvterm'"
	cd /home/derrick/.config/emacs/elpaca/builds/vterm/build/libvterm-prefix/src/libvterm && /usr/bin/cmake -E echo_append
	cd /home/derrick/.config/emacs/elpaca/builds/vterm/build/libvterm-prefix/src/libvterm && /usr/bin/cmake -E touch /home/derrick/.config/emacs/elpaca/builds/vterm/build/libvterm-prefix/src/libvterm-stamp/libvterm-configure

libvterm-prefix/src/libvterm-stamp/libvterm-download: libvterm-prefix/src/libvterm-stamp/libvterm-gitinfo.txt
libvterm-prefix/src/libvterm-stamp/libvterm-download: libvterm-prefix/src/libvterm-stamp/libvterm-mkdir
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --blue --bold --progress-dir=/home/derrick/.config/emacs/elpaca/builds/vterm/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_4) "Performing download step (git clone) for 'libvterm'"
	cd /home/derrick/.config/emacs/elpaca/builds/vterm/build/libvterm-prefix/src && /usr/bin/cmake -DCMAKE_MESSAGE_LOG_LEVEL=VERBOSE -P /home/derrick/.config/emacs/elpaca/builds/vterm/build/libvterm-prefix/tmp/libvterm-gitclone.cmake
	cd /home/derrick/.config/emacs/elpaca/builds/vterm/build/libvterm-prefix/src && /usr/bin/cmake -E touch /home/derrick/.config/emacs/elpaca/builds/vterm/build/libvterm-prefix/src/libvterm-stamp/libvterm-download

libvterm-prefix/src/libvterm-stamp/libvterm-install: libvterm-prefix/src/libvterm-stamp/libvterm-build
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --blue --bold --progress-dir=/home/derrick/.config/emacs/elpaca/builds/vterm/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_5) "No install step for 'libvterm'"
	cd /home/derrick/.config/emacs/elpaca/builds/vterm/build/libvterm-prefix/src/libvterm && /usr/bin/cmake -E echo_append
	cd /home/derrick/.config/emacs/elpaca/builds/vterm/build/libvterm-prefix/src/libvterm && /usr/bin/cmake -E touch /home/derrick/.config/emacs/elpaca/builds/vterm/build/libvterm-prefix/src/libvterm-stamp/libvterm-install

libvterm-prefix/src/libvterm-stamp/libvterm-mkdir:
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --blue --bold --progress-dir=/home/derrick/.config/emacs/elpaca/builds/vterm/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_6) "Creating directories for 'libvterm'"
	/usr/bin/cmake -Dcfgdir= -P /home/derrick/.config/emacs/elpaca/builds/vterm/build/libvterm-prefix/tmp/libvterm-mkdirs.cmake
	/usr/bin/cmake -E touch /home/derrick/.config/emacs/elpaca/builds/vterm/build/libvterm-prefix/src/libvterm-stamp/libvterm-mkdir

libvterm-prefix/src/libvterm-stamp/libvterm-patch: libvterm-prefix/src/libvterm-stamp/libvterm-patch-info.txt
libvterm-prefix/src/libvterm-stamp/libvterm-patch: libvterm-prefix/src/libvterm-stamp/libvterm-update
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --blue --bold --progress-dir=/home/derrick/.config/emacs/elpaca/builds/vterm/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_7) "No patch step for 'libvterm'"
	/usr/bin/cmake -E echo_append
	/usr/bin/cmake -E touch /home/derrick/.config/emacs/elpaca/builds/vterm/build/libvterm-prefix/src/libvterm-stamp/libvterm-patch

libvterm-prefix/src/libvterm-stamp/libvterm-update: libvterm-prefix/tmp/libvterm-gitupdate.cmake
libvterm-prefix/src/libvterm-stamp/libvterm-update: libvterm-prefix/src/libvterm-stamp/libvterm-update-info.txt
libvterm-prefix/src/libvterm-stamp/libvterm-update: libvterm-prefix/src/libvterm-stamp/libvterm-download
	@$(CMAKE_COMMAND) -E cmake_echo_color "--switch=$(COLOR)" --blue --bold --progress-dir=/home/derrick/.config/emacs/elpaca/builds/vterm/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_8) "Performing update step for 'libvterm'"
	cd /home/derrick/.config/emacs/elpaca/builds/vterm/build/libvterm-prefix/src/libvterm && /usr/bin/cmake -Dcan_fetch=YES -DCMAKE_MESSAGE_LOG_LEVEL=VERBOSE -P /home/derrick/.config/emacs/elpaca/builds/vterm/build/libvterm-prefix/tmp/libvterm-gitupdate.cmake

CMakeFiles/libvterm.dir/codegen:
.PHONY : CMakeFiles/libvterm.dir/codegen

libvterm: CMakeFiles/libvterm
libvterm: CMakeFiles/libvterm-complete
libvterm: libvterm-prefix/src/libvterm-stamp/libvterm-build
libvterm: libvterm-prefix/src/libvterm-stamp/libvterm-configure
libvterm: libvterm-prefix/src/libvterm-stamp/libvterm-download
libvterm: libvterm-prefix/src/libvterm-stamp/libvterm-install
libvterm: libvterm-prefix/src/libvterm-stamp/libvterm-mkdir
libvterm: libvterm-prefix/src/libvterm-stamp/libvterm-patch
libvterm: libvterm-prefix/src/libvterm-stamp/libvterm-update
libvterm: CMakeFiles/libvterm.dir/build.make
.PHONY : libvterm

# Rule to build all files generated by this target.
CMakeFiles/libvterm.dir/build: libvterm
.PHONY : CMakeFiles/libvterm.dir/build

CMakeFiles/libvterm.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/libvterm.dir/cmake_clean.cmake
.PHONY : CMakeFiles/libvterm.dir/clean

CMakeFiles/libvterm.dir/depend:
	cd /home/derrick/.config/emacs/elpaca/builds/vterm/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/derrick/.config/emacs/elpaca/builds/vterm /home/derrick/.config/emacs/elpaca/builds/vterm /home/derrick/.config/emacs/elpaca/builds/vterm/build /home/derrick/.config/emacs/elpaca/builds/vterm/build /home/derrick/.config/emacs/elpaca/builds/vterm/build/CMakeFiles/libvterm.dir/DependInfo.cmake "--color=$(COLOR)"
.PHONY : CMakeFiles/libvterm.dir/depend

