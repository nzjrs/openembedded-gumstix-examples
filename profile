#
# Environment setup for oe
#

export BB_ENV_EXTRAWHITE="MACHINE DISTRO ANGSTROM_MODE OVEROTOP OEBRANCH USERBRANCH TITOOLSDIR"

export OVEROTOP="/media/OE"
export OEBRANCH="${OVEROTOP}/org.openembedded.dev"
export USERBRANCH="${OVEROTOP}/user.collection"

export PATH="${OVEROTOP}/bitbake/bin:$PATH"
export BBPATH="${OVEROTOP}/build:${USERBRANCH}:${OEBRANCH}"

export TITOOLSDIR="${OVEROTOP}/ti"

if [ "$PS1" ]; then
   if [ "$BASH" ]; then
     export PS1="\[\033[02;32m\]overo\[\033[00m\] ${PS1}"
   fi
fi

umask 0002

#
# end oe setup
#

#
# utility functions for working with bitbake
#
function __get_kernel ()
{
    _KERNEL=$(bitbake -e 2>/dev/null | grep "^PREFERRED_PROVIDER_virtual/kernel=" | sed 's/"//g' | cut -f 2 -d =)
}

#
function __get_machine ()
{
    _MACHINE=$(bitbake -e 2>/dev/null | grep "^MACHINE_ARCH=" | sed 's/"//g' | cut -f 2 -d =)
}

function bitbake-kernel-print-recipe-name ()
{
    __get_kernel
    echo $_KERNEL
}

function bitbake-kernel-reconfigure ()
{
    __get_kernel
    bitbake -c menuconfig $_KERNEL
}

function bitbake-kernel-rebuild ()
{
    __get_kernel
    bitbake -c rebuild $_KERNEL
}

function bitbake-machine-print-name ()
{
    __get_machine
    echo $_MACHINE
}


