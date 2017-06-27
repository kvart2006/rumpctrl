rrCANDO=true
[ -z "${RUMPCTRL_LOADED}" ] \
    || { echo "rumpctrl env already loaded!"; rrCANDO=false; }

# technically bash commands (PS1), but should mostly work with /bin/sh
#[ "${SHELL}" != "${SHELL%bash}" ] \
#    || { echo "environment requires bash"; rrCANDO=false; }

# enable parameters expansion in the prompt
[ "${SHELL}" = "${SHELL%/zsh}" ] \
    || set -o PROMPT_SUBST

# sed replacement is not run with /g ...
[ "/root/git/rumpctrl" = "XXXPATHXXX" ] && { echo "not preprocessed"; rrCANDO=false; }

rumpctrl_hascmd ()
{
	[ -z "${1}" ] && { echo '#f'; false; return; }
	PATH=${RRPATH}/bin type $1 > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		echo '#t'
	else
		echo '#f'
		false
	fi
}

rumpctrl_hostcmd ()
{

	PATH="${rrPATH}" "$@"
}

if ${rrCANDO}; then
	RRPATH=/root/git/rumpctrl
	RUMPCTRL_LOADED=yes

	# parse args to see if we should set RUMP_SERVER
	# (yes, this is another bash'ism)
	#
	# if the first parameter is -u, set path to unix://${2}
	# (this way you can tab-complete an existing sucket)
	if [ ! -z "$*" ]; then
		case "$1" in
		-u)
			export RUMP_SERVER=unix://${2}
			;;
		*)
			export RUMP_SERVER=${1}
			;;
		esac
	fi

	# clear things like "alias ls=---weird-color-stuffs"
	# XXX: not restored
	unalias -a

	alias rumpctrl_listcmds='for x in $(echo ${RRPATH}/bin/*);
	    do echo ${x##*/};done | column'
	alias cd='echo ERROR: cd not available in rumpctrl mode'

	# save current values
	rrPATH="${PATH}"
	rrPS1="${PS1}"

	# replace env variables
	PS1='rumpctrl (${RUMP_SERVER:-NULL})$ '
	export PS1

	PATH="${RRPATH}/bin:${PATH}"
	export PATH

	alias rumpctrl_unload='
		PS1="${rrPS1}"
		PATH="${rrPATH}"
		unset RUMPCTRL_LOADED
		unset rrPS1
		unset rrPATH
		unalias rumpctrl_listcmds
		unalias rumpctrl_unload
		unalias cd
		unset -f rumpctrl_hascmd
		unset -f rumpctrl_hostcmd
	'
elif [ ! -z "${RUMPCTRL_LOADED}" ]; then
        unset -f rumpctrl_hascmd
        unset -f rumpctrl_hostcmd
fi
