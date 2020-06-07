# ltask

lightweight remote task management

## Usage

    ltask [OPTIONS] TASK TARGET
    Options:
    	-H HOST		Add HOST to target hosts. can be used
    			to target single hosts without defining
    			a custom target
    	-p		Force parallel execution
    	-h		print this help text
## Output

All output from targets is printed to `STDOUT`, prefixed by the hostname.
This also includes text sent to `STDERR`, which is prefixed by `[ERR]`.
Text is displayed "as it comes", not sorted by host.
If required, this can be done afterwards with tools such as `grep`
Status and error messages are printed to `STDERR`.
In Linear execution mode, ltask displays a progress meter.

## How it works

`ltask` executes scripts (`tasks`) on remote hosts and hostgroups (`targets`) via SSH,
either linearly if user input is required, or in parallel.
Tasks and targets are written in bash, thus are very flexible.
No special Software is required, neither on the host nor on the target.

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
    FILES		Array of Files to copy over before script invocation
    INCLUDES		Array of libraries to include
    PARALLEL		Enable parallel execution (true/[false])
    
    # Available in setup
    ASSET_DIR		paht to folder where eg keys are stored
    TOOL_DIR		path to helper script folder

Tasks are stored in `tasks/`

[Example](tasks/example)

### Targets

Targets define hostgroups for tasks to target.
They aren't executed but sourced by ltask, thus must be written in bash.
Hosts are stored in the `HOSTS` array with format `hostname[:port]`.
The port should only be specified if != 22 to avoid double mentions.
`HOSTS` is checked for duplicate, `host:22` and `host` would produce the same result but are not caught by duplicate search.

Targets are stored in `targets/`

[Example](targets/example)

### Libraries

Libraries are scripts which are executed on the remote host before the main task.
Their purpose is to define generic interfaces for different types of hosts.

Libraries are stored in `libs/`

[Example](libs/pkgmanager)

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

