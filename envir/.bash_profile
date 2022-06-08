export BASH_SILENCE_DEPRECATION_WARNING=1
#eval "$(/opt/homebrew/bin/brew shellenv)"
function nonzero_return() {
	RETVAL=$?
	[ $RETVAL -ne 0 ] && echo "$RETVAL"
}

function parse_git_branch() {
	BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
	if [ ! "${BRANCH}" == "" ]
	then
		STAT=`parse_git_dirty`
		echo "[${BRANCH}${STAT}]"
	else
		echo ""
	fi
}
function parse_git_dirty {
	status=`git status 2>&1 | tee`
	dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
	untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
	ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
	newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
	renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
	deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
	bits=''
	if [ "${renamed}" == "0" ]; then
		bits="_>${bits}"
	fi
	if [ "${ahead}" == "0" ]; then
		bits="_*${bits}"
	fi
	if [ "${newfile}" == "0" ]; then
		bits="_+${bits}"
	fi
	if [ "${untracked}" == "0" ]; then
		bits="_?${bits}"
	fi
	if [ "${deleted}" == "0" ]; then
		bits="_x${bits}"
	fi
	if [ "${dirty}" == "0" ]; then
		bits="_!${bits}"
	fi
	if [ ! "${bits}" == "" ]; then
		echo " _${bits}"
	else
		echo ""
	fi
}

function set_virtualenv () {
  if test -z "$VIRTUAL_ENV" ; then
      PYTHON_VIRTUALENV=""
  else
      PYTHON_VIRTUALENV="_${GREEN}(`basename \"$VIRTUAL_ENV\"`)${COLOR_NONE} "
  fi
}
#export PS1="┌──>\t \[\e[33m\]\u\[\e[m\]@\[\e[34m\]\h\[\e[m\]:\[\e[32m\]\s\[\e[m\]->\[\e[35m\]\w\[\e[m\]:\`parse_git_branch\`\\n└──( \$\`nonzero_return\'"
export PS1="┌─<\[\e[37m\]\t \[\e[33m\]\u\[\e[m\]@\[\e[34m\]\h\[\e[m\]:\[\e[32m\]\s\[\e[m\]->\[\e[35m\]\w\[\e[m\]\`parse_git_branch\`\`set_virtualenv\`\n└─(\$\`nonzero_return\` " 

complete -C /opt/homebrew/bin/terraform terraform
