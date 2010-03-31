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
###
# bashsplit
### 
# $1 to $n  would be the strings to split up.
#
function bashsplit()
{   
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
    if [ "${1}" -ne "0" ]; then
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
    HOSTIS=`hostname -s` # a non bash specific way to find the host
    USERIS=`whoami`
    config=`ls -d $1/configs/*.conf | grep $HOSTIS_$USERIS`
    check_errs $? "Did not find configuration file $HOSTIS_$USERIS.conf in directory $1/configs/"
    config=`ls -d $1/configs/*.conf | grep $HOSTIS`
    check_errs $? "Did not find configuration file $HOSTIS.conf in directory $1/configs/"
#    echo "config variable has population : "   # 1>> $OUTPUT 2>> $OUTPUT  #test statement
#    echo $config   # 1>> $OUTPUT 2>> $OUTPUT                 #test statement
    if [ $DEBUG -ge 10 ]  
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
    distributionlist=`cat $STARTDIR/distributionlist.sh | cut -d "#" -f 1| cut -d"_" -f 1`
}

###
# load vars
###
# function to load config ... trying . filename load
function loadvars ()
{
 
    . $1  # trying this may have to use source
    check_errs $? "Configuration file $1 failed to load"
}

###
# fixes the configsvars 
###
function fixconfigsvars () 
{
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
    eval varstogenerate=\${$1[@]} 
    if [ $DEBUG -ge 5 ]
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
	if [ $DEBUG -ge 10 ]
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
	    if [ $DEBUG -ge 25 ]
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
	    if [ $DEBUG -ge 15 ]
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
	    
		if [ $DEBUG -ge 5 ]
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
	if [ $DEBUG -ge 6 ]
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
function configsvars () {

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
function clearconfigsvars () {
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
# save shell environment
###
# saves the environment that would be modified by the script when called
function save_environment () { 
    if [ $DEBUG -ge 15 ]
    then 
	echo saving environment
    fi
    calldir=`pwd`
    if [ $DEBUG -ge 10 ]  
    then
	echo "saving current directory $calldir"   # 1>> $OUTPUT 2>> $OUTPUT  #test statement
    fi
    oldumask=`umask`
    if [ $DEBUG -ge 10 ]  
    then
	echo "saving current umask $oldumask"   # 1>> $OUTPUT 2>> $OUTPUT     #test statement
    fi
}
###
# set shell environment
###
# sets up the defaul environment variables that the civmscript scripts
function set_default_environment () {
    if [ $DEBUG -ge 15 ]
    then 
	echo setting environment
    fi
    cd $STARTDIR #set working dir                                                   
    if [ $DEBUG -ge 10 ]  
    then
	echo "set current directory to"   # 1>> $OUTPUT 2>> $OUTPUT  #test statement         
	echo `pwd`                        # 1>> $OUTPUT 2>> $OUTPUT  #test statement        
    fi
    umask $civmumask #set umask, this variable should be read from a configuration file
    if [ $DEBUG -ge 10 ]  
    then
	echo "set umask to "   # 1>> $OUTPUT 2>> $OUTPUT             #test statement         
	echo `umask`           # 1>> $OUTPUT 2>> $OUTPUT             #test statement         
    fi
}
###
# restore shell environment
###
# restores the environment that was modified by the script when called      
function restore_environment () {
    umask $oldumask     #restores umask                                         
    if [ $DEBUG -ge 10 ]  
    then
	echo "set umask to"   # 1>> $OUTPUT 2>> $OUTPUT                  #test statement
	echo `umask`   # 1>> $OUTPUT 2>> $OUTPUT                          #test statement
    fi
    cd $calldir         #bring us back to the directory we called this from     
    if [ $DEBUG -ge 10 ]  
    then
	echo "set current directory to"   # 1>> $OUTPUT 2>> $OUTPUT       #test statement
	echo `pwd`   # 1>> $OUTPUT 2>> $OUTPUT                            #test statement
    fi
}