#############notascripbut alibraryfor scripts #!/bin/bash to be used with . $file inclusion
################################################################################
# Comon functions for the civm scripts with config directories
# requires variable definitions
# STARTDIR
# bashsplit - splits a string into an array and returns the array
# check_errs - checks last command for error. Takes two arguments , error code, message
#
# whatconfigs - gets the configs from to use from $1/configs/* . Takes one argument, script directory
# whathosts - gets the list of hosts from distributionlist.sh
#
# loadvars - loads whatever is in the config file... should probably fix this up to onl load variables
# fixconfigsvars - fixes the variables which are goofy or otherwise difficult to handle
# generate_groupvars - makes group vars based off files given to it
# configvars  - print variables in configs
# clearconfigsvars - clears all the config vars and sets them to 0
#
# get_free_uid - get next free uid over 1000
# get_free_gid - get next free gid over 500
# check_uid - check to see that we're the root user(or we've used sudo)
# display_usage - display script usage info, which is embeded in script prior to this being called
# get_version - gets the civmscript version
# display_version - display version infol, which is embeded in script prior to this being called
# find_standard_utils - finds the standard util programs required by script
#
# save_environment - save shell environment
# set_default_environment - set shell variables for civmautmounter scripts
# restore_environment - restore shell environment
################################################################################
# version 3
# -expand to support civmautomounter
# Version 2 used by civmconfigcollector and civmbackup
# -added civmbackup support
# version 1 used by civmconfigcollector
# -created from civmautomounter's function library, inted to expand to each new
#  civmconsole launchd script
################################################################################
#
DEBUG=100
script_name=$0
###
# bashsplit
###
# $1 to $n  would be the strings to split up.
#
function bashsplit()
{
    if [ $DEBUG -ge 100 ]
    then 
	echo FUNCTIONCALL: $FUNCNAME :: DEBUGLVL $DEBUG
    fi
#    [:space:]

    SaveIFS=$IFS
    IFS="${1}"
# $* is all the arguments given listed as a space seperated string. So, its just a single string with each argument given to the function seperated by a space. THis means that if we have spaces where e dont want a split this wont work.
    declare -a Array=($*)
    IFS=$SaveIFS
    return $Array[*]
}

###
# check_errs ripped from the web
###
# can be called after a syscall to check out the error message....
# Function. Parameter 1 is the return code
# Para. 2 is text to display on failure.
function check_errs()
{
    if [ $DEBUG -ge 100 ]
    then 
	echo FUNCTIONCALL: $FUNCNAME :: DEBUGLVL $DEBUG
    fi
    if [ "${1}" -ne "0" ];
    then 
	if [ $DEBUG -ge 1 ]
	then
	    echo "ERROR # ${1} : ${2}"
	fi
	# as a bonus, make our function exit with the right error code.
	return ${1}
    fi
}

###
# whatconfigs
###
# puts the config files's path into a variable.
# takes 1 argument, the civmscript directory
# Get the configs variable files to load from $1/configs
function whatconfigs ()
{
    if [ $DEBUG -ge 100 ]
    then 
	echo FUNCTIONCALL: $FUNCNAME :: DEBUGLVL $DEBUG
    fi

    HOSTIS=`hostname -s` # a non bash specific way to find the host
    USERIS=`whoami`
# exec fd direction(<>) filename
    exec 100>/dev/null  # open devnull(bit bucket) for writing at random fdval
    #i>&j   fd to fd redirection basics
    exec 50>&2 # save fd 2 into 50
    exec 2>&100  # route fd2 to 100(bit bucket) : )
    if [ `ls configs/*conf | wc -l` == "1" ]
    then # if there is only one plist thats the one we want
	config=`ls configs/*conf`  # One config to rule them all.
	if [ $DEBUG -ge 25 ]
	then
	    echo One config file found. : $config
	fi
    elif [ `ls configs/*${HOSTIS}*conf | grep -v "civmscript.conf" | wc -l` == "1" ]
    then # if there is only one conf with the hostname in it thats the one we want
	config=`ls configs/*${HOSTIS}*conf `
	if [ $DEBUG -ge 25 ]
	then
	    echo One config file with hostname found. : $config
	fi
    elif [ `ls configs/*${HOSTIS}*${USERIS}*conf | grep -v "civmscript.conf" | wc -l` == "1" ]
    then
	config=`ls configs/*${HOSTIS}*${USERIS}*conf `
	if [ $DEBUG -ge 25 ]
	then
	    echo One config file with hostname username found. : $config
	fi
    else
	if [ $DEBUG -ge 15 ]
	then
	    echo WARNING: No config file with hostname or hostname username found. 
	fi
	
    fi
    exec 100>&- #close bitbucket
    exec 2>&50 # put stderrback
    exec 50>&-  # close temp descriptor 
#    config=`basename $config`
    check_errs $? "Did not find configuration file  in directory $1/configs/"
#    echo "config variable has population : "   # 1>> $OUTPUT 2>> $OUTPUT  #test statement
#    echo $config   # 1>> $OUTPUT 2>> $OUTPUT                 #test statement
    if [ $DEBUG -ge 25 ]
    then
	echo "Found config $config"
    fi

}

###
# whathosts
###
# puts the list of hosts in distribution list into the distibutionlist var
function whathosts()
{
    if [ $DEBUG -ge 100 ]
    then 
	echo FUNCTIONCALL: $FUNCNAME :: DEBUGLVL $DEBUG
    fi
    distributionlist=`cat $STARTDIR/distributionlist.sh | cut -d "#" -f 1| cut -d"_" -f 1`
}

###
# load vars
###
function loadvars ()
{
    if [ $DEBUG -ge 100 ]
    then 
	echo FUNCTIONCALL: $FUNCNAME :: DEBUGLVL $DEBUG
    fi

    . $1  # soucing files
    check_errs $? "Configuration file $1 failed to load: possible permission issue?"
}

###
# fixes the configsvars
###
function fixconfigsvars ()
{
    if [ $DEBUG -ge 100 ]
    then 
	echo FUNCTIONCALL: $FUNCNAME :: DEBUGLVL $DEBUG
    fi
    ###
    # Clean up directories with spaces... somehow
    ###
    # how to do this on the fly... not sure
    # examain paths for validity... else add a \  (slash escape) and the next value
    for file in $files
    do
	sleep 0
	#if not exist file
	# does file\ file+1 exist
	# repeat until one works... fail after 4 return an error code?
    done
}
###
# escapestr_sed()
###
# read a stream from stdin and escape characters in text that could be interpreted as
# special characters by sed
function escape_sed()
{
    if [ $DEBUG -ge 100 ]
    then 
	echo FUNCTIONCALL: $FUNCNAME :: DEBUGLVL $DEBUG
    fi
    sed \
	-e 's/\//\\\//g' \
	-e 's/\&/\\\&/g'
}

###
# generate_groupvars
###
# should build the group vars regardless of how many there should be.
# requires that a groups variable be defined,
#   the groups variable should contain the SINGULAR name of the groups to create, eg DESTINATION would create DESTINATIONS
function generate_groupvars ()
{
    if [ $DEBUG -ge 100 ]
    then 
	echo FUNCTIONCALL: $FUNCNAME :: DEBUGLVL $DEBUG
    fi
    eval varstogenerate=\${$1[@]}
    if [ $DEBUG -ge 55 ]
    then
	echo Found Groups: ${varstogenerate[@]}
	echo $1
    fi
    for GROUPNAME in ${varstogenerate[@]}
    do
	i=1 # individual group loop
	again=1 # individual loop control, loops while 1
	# create groupointer pointing to {GROUPNAME}S
	eval grouppointer=${GROUPNAME}S
	if [ $DEBUG -ge 60 ]
	then
	    echo Groupname        : ${GROUPNAME}
	    echo Groupnamepointer : $grouppointer
	    eval echo Valofpointeddata : \${$grouppointer[@]}
	fi


	# do something here, per group we expect to have
#	sleep 0


	# build groupvars from remotelogfile1-n
	while(test $again -ne 0 )
	do
	    varname=$(echo $GROUPNAME$i)
	    ###
	    # examplecodes
	    ###
	    if [ $DEBUG -ge 55 ]
	    then
		echo VARIABLENAME is $GROUPNAME$i # this echos the name correctly
		#varname=$(echo $GROUPNAME$i)
		# this stores the correct dynamic name in a variable of use as a pointer
		eval echo contents of $varname \$$varname
		# this shows the contents of REMOTELOGFILE$i using pointer-like dereferencing


		eval echo again \$$(echo $GROUPNAME$i)
		eval echo Last time \$$(echo $varname)
		# this too shows the contents. skiping some steps
		#eval echo Last time \$$[echo REMOTELOGFILE$i]
		# this fails... i would think it would work and just not spawn a subshell...
		#echo VARIABLECONTENTS is `eval  $REMOTELOGFILE$i`
		# this doesnt work... why not.... its trying to echo $REMOTELOGFILE followed by $i
		# varname is VARIABLE$i
		# contents is eval \$$(echo VARIABLE$i)
	    fi


	    # varname's value
	    eval varnameval=\$$(echo $varname)
	    if [ $DEBUG -ge 60 ]
	    then
		echo varnames $varname value is $varnameval # the value of $groupname$i
	    fi

	    # this ${var:+something} is a way to test for
	    # a variable existing and not being null. that
	    # is its value is "something" only if var is
	    # defined and not null
	    if [ -n "${varnameval:+exists}" ] # something fishy here
	    #``&& [ ! "${varname+xxx}" = "xxx" ]
	    then
	    # this works.

		if [ $DEBUG -ge 60 ]
		then
		    eval echo joining $GROUPNAME$i :  \$$(echo $GROUPNAME$i)
		    eval echo ${GROUPNAME}S contents before adding : \${$grouppointer[@]}
		fi
		#eval REMOTELOGFILES=(${REMOTELOGFILES[@]}  \$$(echo REMOTELOGFILE$i) )
		echo eval "$grouppointer=(\${$grouppointer[@]} \$$(echo $varname) )"
		eval "$grouppointer=(\${$grouppointer[@]} \$$(echo $varname) )"
		# this has an issue as it only joins the first entry of the array to the new entry eliminating entries in between.
		again=1
	    else
		again=0
	    fi
	    eval echo ${GROUPNAME}S contents after adding $varname : \${$grouppointer[@]}
	    let i=i+1;
#	    sleep 0
	done
	if [ $DEBUG -ge 60 ]
	then
	    eval echo $GROUPNAME contents after building : \${$grouppointer[@]}
	fi

    # dynamically build the remotelogdirs array from the remotelogs array
#    for ((i=0 ;i<${#REMOTELOGFILES[@]} ;i++))
#    do
#	REMOTELOGDIRS=($REMOTELOGDIRS `dirname ${REMOTELOGFILES[${i}]}`)
#    done
    # make each element of an arbitrary array unique
#    REMOTELOGDIRS=$(for element in  `echo ${REMOTELOGDIRS[@]}` ; do echo $element ; done | sort -u)
    done
    return 0
}
#if [ -z "${VAR+xxx}" ]; then echo VAR is not set at all; fi
#if [ -z "$VAR" ] && [ "${VAR+xxx}" = "xxx" ]; then echo VAR is set but empty; fi

###
# print variables
###
# print out the standard variables in an configs should use the output/error redirs
# be nice if it was able to pick up on any variable in the script
function configsvars () 
{
    if [ $DEBUG -ge 100 ]
    then 
	echo FUNCTIONCALL: $FUNCNAME :: DEBUGLVL $DEBUG
    fi

    echo "configfiles are $CONFIGFILES"   # 1>> $OUTPUT 2>> $OUTPUT      #Debug
    if $jesus==hotdigity
    then
	echo "sharetype is $SHARETYPE"   # 1>> $OUTPUT 2>> $OUTPUT      #Debug
	echo "servername is $SERVER"   # 1>> $OUTPUT 2>> $OUTPUT        #Debug
	echo "base mount dir is $SHAREDIR"   # 1>> $OUTPUT 2>> $OUTPUT  #Debug
	echo "sharename is $SHARENAME"   # 1>> $OUTPUT 2>> $OUTPUT      #Debug
	echo "mountname is $MOUNTNAME"   # 1>> $OUTPUT 2>> $OUTPUT      #Debug
	echo "username is $UNAME"   # 1>> $OUTPUT 2>> $OUTPUT           #Debug
	echo "password is $PWORD"   # 1>> $OUTPUT 2>> $OUTPUT           #Debug
	echo "workgroup is $WORKGROUP"   # 1>> $OUTPUT 2>> $OUTPUT      #Debug
	echo "mountopts are $MOUNTOPTS"   # 1>> $OUTPUT 2>> $OUTPUT     #Debug
	echo "mountpoint is $MOUNTPOINT"   # 1>> $OUTPUT 2>> $OUTPUT    #Debug
    fi
}
###
# clear variables
###
# clears the variables for the next run of the script. It might be better to use unset
function clearconfigsvars () 
{
    if [ $DEBUG -ge 100 ]
    then 
	echo FUNCTIONCALL: $FUNCNAME :: DEBUGLVL $DEBUG
    fi
    CONFIGFILES="0"
# mscript vars are irrelevant should find good way to tell what type of script called this function and then act appropiately.
    if $jesus==hotdigity
    then
	SHARETYPE="0"
	SERVER="0"
	SHAREDIR="0"
	SHARENAME="0"
	MOUNTNAME="0"
	UNAME="0"
	PWORD="0"
	WORKGROUP="0"
	MOUNTOPTS="0"
	MOUNTPOINT="0"
    fi
}
###
# get a free GID greater than 1000
###
function get_free_uid () 
{
    if [ $DEBUG -ge 100 ]
    then 
	echo FUNCTIONCALL: $FUNCNAME :: DEBUGLVL $DEBUG
    fi
    
    continue="no"
    number_used="dontknow"
    fnumber=6000
    until [ $continue = "yes" ] ; do
	if [ `$dscl . -list ${dsclroot}/Users uid | $sed -e 's/blank:\{1,\}/:/g' | $cut -f 2 -d : | $grep -c "^$fnumber$"` -gt 0 ] ;
	then 
	    number_used=true
	else
	    number_used=false
	fi
	if [ $number_used = "true" ] ;
	then 
	    fnumber=`$expr $fnumber + 1`
	else
	    CREATEUID="$fnumber"
	    continue="yes"
	fi
    done;
    return
}
###
# get a free GID greater than 500
###
#
function get_free_gid () 
{
    if [ $DEBUG -ge 100 ]
    then 
	echo FUNCTIONCALL: $FUNCNAME :: DEBUGLVL $DEBUG
    fi
    
    continue="no"
    number_used="dontknow"
    fnumber=500
    until [ $continue = "yes" ] ; do
	if [ `$dscl . -list ${dsclroot}/Groups gid | $sed -e 's/blank:\{1,\}/:/g' | $cut -f 2 -d : | $grep -c "^$fnumber$"` -gt 0 ] ;
	then 
	    number_used=true
	else
	    number_used=false
	fi
	if [ $number_used = "true" ] ;
	then 
	    fnumber=`$expr $fnumber + 1`
	else
	    group_id="$fnumber"
	    continue="yes"
	fi
    done;
    return
}
###
# check if the scripts is run by the root user
###
function check_uid () 
{
    if [ $DEBUG -ge 100 ]
    then 
	echo FUNCTIONCALL: $FUNCNAME :: DEBUGLVL $DEBUG
    fi
    
    if [ "`whoami`" = root ] ;
    then 
	uID=0
    else
	if [ "$uID" = "" ] ;
	then 
	    uID=-1
	fi
    fi
    export uID
    return
}
###
# display script usage
###
#
function display_usage ()
{
    if [ $DEBUG -ge 100 ]
    then 
	echo FUNCTIONCALL: $FUNCNAME :: DEBUGLVL $DEBUG
    fi
    
    usage_indent='               '
    >&2 echo "Usage: $script_name [-u uid [-o]] [-g group] [-G group,...]"
    >&2 echo "${usage_indent}[-d home] [-m [-k template]] [-s shell] [-r Full Name]"
    >&2 echo "${usage_indent}[-c work description] "
    >&2 echo "${usage_indent}[-C localcollaborator] "
    >&2 echo "${usage_indent}([-f inactive] | [-e expire] |  [-T timeframe] )"
    >&2 echo "${usage_indent}[-p passwd] user"
    >&2 echo "${usage_indent}civmdscluseradd.bash -u 6000 -g ftpnoncivm -r "Full Name" -c "brain atlasing" -C localCollaborator fname "
    >&2 echo "${usage_indent}civmdscluseradd.bash -u 6000 -g ftpgrp -G ftpWgrp,ftpnoncivm -r "Full Name" -c "brain atlasing" -C localCollaborator fname "
    >&2 echo "${usage_indent}civmdscluseradd.bash -u 6000 -g ftpgrp -G ftpWgrp -r "Local User" luser "
    exit $1
}
###
# get version
###
function get_version ()
{
    if [ $DEBUG -ge 100 ]
    then 
	echo FUNCTIONCALL: $FUNCNAME :: DEBUGLVL $DEBUG
    fi
    version=`ls $SCRIPTDIR/v* | grep -E "^v[0-9]+[.]*[0-9]*" | tail -n 1| cut -d"v" -f2`
    if [ -z "$version" ]
    then
	version=000
    fi
}
###
# display script version
###
# displays version from $version variable in script
function display_version ()
{
    if [ $DEBUG -ge 100 ]
    then 
	echo FUNCTIONCALL: $FUNCNAME :: DEBUGLVL $DEBUG
    fi
    
    >&2 echo "$script_name: version $version by Francois Corthay"
    >&2 echo "based on $script_name by Chris Roberts"
    exit $1
    return
}
###
# find the shell utils we need
###
#
function find_standard_utils ()
{
    if [ $DEBUG -ge 100 ]
    then 
	echo FUNCTIONCALL: $FUNCNAME :: DEBUGLVL $DEBUG
    fi
    
              # find dscl
    dscl=`which dscl`
    if [ ! -x "$dscl" ] ;
    then 
	>&2 echo "$script_name: unable to find/use dscl"
	exit 10
    fi
         # find ditto
    ditto=`which ditto`
    if [ ! -x "$ditto" ] ;
    then 
	>&2 echo "$script_name: unable to find/use ditto"
	exit 10
    fi
           # find cut
    cut=`which cut`
    if [ ! -x "$cut" ] ;
    then 
	>&2 echo "$script_name: unable to find/use cut"
	exit 10
    fi
          # find expr
    expr=`which expr`
    if [ ! -x "$expr" ] ;
    then 
	>&2 echo "$script_name: unable to find/use expr"
	exit 10
    fi
          # find grep
    grep=`which grep`
    if [ ! -x "$grep" ] ;
    then 
	>&2 echo "$script_name: unable to find/use grep"
	exit 10
    fi
           # find sed
    sed=`which sed`
    if [ ! -x "$sed" ] ;
    then 
	>&2 echo "$script_name: unable to find/use sed"
	exit 10
    fi
          # find head
    head=`which head`
    if [ ! -x "$head" ] ;
    then 
	>&2 echo "$script_name: unable to find/use head"
	exit 10
    fi
          # find tail
    tail=`which tail`
    if [ ! -x "$tail" ] ;
    then 
	>&2 echo "$script_name: unable to find/use tail"
	exit 10
    fi
            # find rm
    rm=`which rm`
    if [ ! -x "$rm" ] ;
    then 
	>&2 echo "$script_name: unable to find/use rm"
	exit 10
    fi
    return 
}
###
# save shell environment
###
# saves the environment that would be modified by the script when called
function save_environment () 
{
    if [ $DEBUG -ge 100 ]
    then 
	echo FUNCTIONCALL: $FUNCNAME :: DEBUGLVL $DEBUG
    fi
    if [ $DEBUG -ge 20 ]
    then
	echo saving environment
    fi
    calldir=`pwd`
    if [ $DEBUG -ge 25 ]
    then
	echo "saving current directory $calldir"   # 1>> $OUTPUT 2>> $OUTPUT  #test statement
    fi
    oldumask=`umask`
    if [ $DEBUG -ge 25 ]
    then
	echo "saving current umask $oldumask"   # 1>> $OUTPUT 2>> $OUTPUT     #test statement
    fi
}
###
# set shell environment
###
# sets up the defaul environment variables that the civmscript scripts
function set_default_environment () 
{
    if [ $DEBUG -ge 100 ]
    then 
	echo FUNCTIONCALL: $FUNCNAME :: DEBUGLVL $DEBUG
    fi
    if [ $DEBUG -ge 20 ]
    then
	echo setting environment
    fi
    cd $STARTDIR #set working dir
    if [ $DEBUG -ge 25 ]
    then
	echo "set current directory to"   # 1>> $OUTPUT 2>> $OUTPUT  #test statement
	echo `pwd`                        # 1>> $OUTPUT 2>> $OUTPUT  #test statement
    fi
    umask $civmumask #set umask, this variable should be read from a configuration file
    if [ $DEBUG -ge 25 ]
    then
	echo "set umask to "   # 1>> $OUTPUT 2>> $OUTPUT             #test statement
	echo `umask`           # 1>> $OUTPUT 2>> $OUTPUT             #test statement
    fi
}
###
# restore shell environment
###
# restores the environment that was modified by the script when called
function restore_environment () 
{
    if [ $DEBUG -ge 100 ]
    then 
	echo FUNCTIONCALL: $FUNCNAME :: DEBUGLVL $DEBUG
    fi
    umask $oldumask     #restores umask
    if [ $DEBUG -ge 25 ]
    then
	echo "set umask to"   # 1>> $OUTPUT 2>> $OUTPUT                  #test statement
	echo `umask`   # 1>> $OUTPUT 2>> $OUTPUT                          #test statement
    fi
    cd $calldir         #bring us back to the directory we called this from
    if [ $DEBUG -ge 25 ]
    then
	echo "set current directory to"   # 1>> $OUTPUT 2>> $OUTPUT       #test statement
	echo `pwd`   # 1>> $OUTPUT 2>> $OUTPUT                            #test statement
    fi
}