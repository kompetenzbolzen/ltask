# ltask

lightweight remote task management

## Usage

    ltask [OPTIONS] TASK TARGET
    Options:
    	-H HOST		Add HOST to target hosts. can be used
    			to target single hosts without defining
    			a custom target
    	-h		print this help text

## How it works

`ltask` executes scripts (`tasks`) on remote hosts and hostgroups (`targets`) vis SSH.
Tasks can be written in sh or bash.
Only the interpreter and an ssh-key accessible user account has to be set up on the target.

### Tasks

A task contains two parts: the setup and the execution.
Setup is executed by ltask on the master machine to set configuration variables like username and which SSH identity to use,
Execution is run on targets.

The task has to decide which part to run based on the envvar `HOSTMODE=yes`, which is only set in the host environment.
If `HOSTMODE` is empty/not set it defaults to execution mode.
The setup must set the `TASK_ISSET` variable to any non-empty value on success.

Reference for environment variables

    # To be set by task
    SSH_USER		username to connect as
    SSH_IDENTITY	path to ssh-key used for authentification of specified user
    
    # Available in setup
    ASSET_DIR		paht to folder where eg keys are stored
    TOOL_DIR		path to helper script folder

Tasks are stored in `tasks/`

### Targets

Targets define hostgroups for tasks to target.
They aren't executed but sourced by ltask, thus must be written in bash.
Hosts are stored in the `HOSTS` array with format `hostname[:port]`.
The port should only be specified if != 22 to avoid double mentions.
`HOSTS` is checked for duplicate, `host:22` and `host` would produce the same result but are not caught by duplicate search.

Targets are stored in `targets/`

## License

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

