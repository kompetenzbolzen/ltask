#!/bin/bash

#    rexec.sh
#    ltask lightweight remote task execution
#    Copyright (C) 2020 Jonas Gunz <himself@jonasgunz.de>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

ARGC=$#
ARGV=($@)

SSH_IDENTITY=~/.ssh/id_rsa
SSH_PORT=22
SSH_HOST=

SSH_OPTIONS="-q -o NumberOfPasswordPrompts=0 -o StrictHostKeyChecking=no"
SSH="ssh $SSH_OPTIONS"

SCRIPT_FILES=()
SCRIPT_INTERPRETER=/bin/sh

FILES=()

function parse_args() {
	for (( i=0; i < $ARGC;i++ )); do
		local ARGREGEX="^-.*"
		if [[ ! ${ARGV[$i]} =~ $ARGREGEX ]]; then
			[ -z $SSH_HOST ] && SSH_HOST=${ARGV[$i]} && continue
			SCRIPT_FILES+=(${ARGV[$i]})
			continue
		fi

		case ${ARGV[$i]} in
			-p)
				i=$((i+1))
				SSH_PORT=${ARGV[$i]};;
			-s)
				i=$((i+1))
				SSH=${ARGV[$i]} $SSH_OPTIONS;;
			-i)
				i=$((i+1))
				SSH_IDENTITY=${ARGV[$i]};;
			-f)
				i=$((i+1))
				FILES+=(${ARGV[$i]});;
			-h)
				print_help 0;;
			*)
				echo Invalid Argument ${ARGV[$i]}
				echo $0 -h for help
				exit 1;;
		esac
	done
	
	[ -z $SSH_HOST ] && echo No host specified && exit 1
	[ ${#SCRIPT_FILES[@]} -eq 0 ] && echo No script specified && exit 1
}

function print_help() {
	cat << EOF
Execute a script on a remote host via SSH

Usage:
$0 [OPTIONS] [USER@]HOST SCRIPT
	-p <PORT>	SSH port (default: 22)
	-s <SSH>	Custom SSH program
	-i <IDENTITY>	SSH Identity file (default: ~/.ssh/id_rsa.pub)
	-f FILE		Copy FILE to target before execution
	-h		Print this help text
EOF
	exit $1
}

parse_args

[ ${#FILES[@]} -gt 0 ] && scp $SSH_OPTIONS -i $SSH_IDENTITY -P $SSH_PORT ${FILES[@]} $SSH_HOST:

cat ${SCRIPT_FILES[@]} | $SSH -p $SSH_PORT -i $SSH_IDENTITY $SSH_HOST '/bin/bash 2> >(while read line; do echo [ERR] $line; done)' 2>/dev/null
exit $?
