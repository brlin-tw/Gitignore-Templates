#!/usr/bin/env bash
# shellcheck disable=SC2034
# Comments prefixed by BASHDOC: are hints to specific GNU Bash Manual's section:
# https://www.gnu.org/software/bash/manual/

## init function: program entrypoint
init(){
	install\
		--verbose\
		--mode=u=rw,go=r\
		-D\
		--target-directory\
		"$(determine_install_directory)"\
		"${RUNTIME_EXECUTABLE_DIRECTORY}/"*.template\
		"${RUNTIME_EXECUTABLE_DIRECTORY}/"*.desktop\
		&& printf "Installation successful.\n"\
		|| printf "Error: Installation failed.\n" 1>&2
	exit "${?}"
}; declare -fr init

check_runtime_dependencies(){
	for executable_name in \
		basename\
		realpath\
		dirname\
		install
	do
		if ! command -v "${executable_name}" &>/dev/null; then
			printf "%s: Error: Runtime dependency \"%s\" not found, please check your dependency installation\n" "${RUNTIME_EXECUTABLE_NAME}" "${executable_name}" 1>&2
			exit 1
		fi
	done
}; declare -fr check_runtime_dependencies; check_runtime_dependencies

determine_install_directory(){
	if [ "${#}" -ne 0 ]; then
		printf "%s: Error: function quantity illegal" "${FUNCNAME[0]}" 1>&2
		return 1
	fi

	local fallback_path="${HOME}/Templates"

	# For $XDG_TEMPLATES_DIR
	if [ -f "${HOME}"/.config/user-dirs.dirs ];then
		# external file, disable check
		#shellcheck disable=SC1090
		source "${HOME}"/.config/user-dirs.dirs

		if [ -v XDG_TEMPLATES_DIR ] && [ -n "${XDG_TEMPLATES_DIR}" ]; then
			printf "%s" "${XDG_TEMPLATES_DIR}"
			return 0
		else
			printf "%s" "${fallback_path}"
			return 0
		fi
	else
		printf "%s" "${fallback_path}"
		return 0
	fi
}; readonly -f determine_install_directory

## Makes debuggers' life easier - Unofficial Bash Strict Mode
## http://redsymbol.net/articles/unofficial-bash-strict-mode/
## BASHDOC: Shell Builtin Commands - Modifying Shell Behavior - The Set Builtin
### Exit prematurely if a command's return value is not 0(with some exceptions), triggers ERR trap if available.
set -o errexit

### Trap on `ERR' is inherited by shell functions, command substitutions, and subshell environment as well
set -o errtrace

### Exit prematurely if an unset variable is expanded, causing parameter expansion failure.
set -o nounset

### Let the return value of a pipeline be the value of the last (rightmost) command to exit with a non-zero status
set -o pipefail

## Non-overridable Primitive Variables
##
## BashFAQ/How do I determine the location of my script? I want to read some config files from the same place. - Greg's Wiki
## http://mywiki.wooledge.org/BashFAQ/028
RUNTIME_EXECUTABLE_FILENAME="$(basename "${BASH_SOURCE[0]}")"
declare -r RUNTIME_EXECUTABLE_FILENAME
declare -r RUNTIME_EXECUTABLE_NAME="${RUNTIME_EXECUTABLE_FILENAME%.*}"
RUNTIME_EXECUTABLE_DIRECTORY="$(dirname "$(realpath --strip "${0}")")"
declare -r RUNTIME_EXECUTABLE_DIRECTORY
declare -r RUNTIME_EXECUTABLE_PATH_ABSOLUTE="${RUNTIME_EXECUTABLE_DIRECTORY}/${RUNTIME_EXECUTABLE_FILENAME}"
declare -r RUNTIME_EXECUTABLE_PATH_RELATIVE="${0}"
declare -r RUNTIME_COMMAND_BASE="${RUNTIME_COMMAND_BASE:-${0}}"

trap_errexit(){
	printf "An error occurred and the script is prematurely aborted\n" 1>&2
	return 0
}; declare -fr trap_errexit; trap trap_errexit ERR

trap_exit(){
	return 0
}; declare -fr trap_exit; trap trap_exit EXIT

init "${@}"

## This script is based on the GNU Bash Shell Script Template project
## https://github.com/Lin-Buo-Ren/GNU-Bash-Shell-Script-Template
## and is based on the following version:
declare -r META_BASED_ON_GNU_BASH_SHELL_SCRIPT_TEMPLATE_VERSION="v1.24.1"
## You may rebase your script to incorporate new features and fixes from the template