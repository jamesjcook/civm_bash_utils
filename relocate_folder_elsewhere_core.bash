#!/bin/bash
# Relocatoooorrrr
# requires one arg, optionally can give 3 args. 
# arg 1 is what is being relocated, using this it auto guesses which device from<->to
# arg 2 is where we'll send for when we feel like being explicit.
# arg 3 is how many tries we should give, default is 5. 
#       This is to combat system flakiness.
source_folder=$1;
target_folder=$2;
max_attempts=$3;

#user=`whoami`;# This is a system provided variable( in all caps). 
# Check for existing variaobles using "env" or the more comprehensive "set" command. 

#echo "current directory: $PWD";
#echo $#
#echo $1
#echo $2
#echo $3


default_target_disk='nas4';
reverse_target_disk='glusterspace';
# PERM_CODE is used for mkdir calls
# this is read/write for user and group but not other. 
# Maybe group shouldnt be granted write to each users's space...
PERM_CODE=755; 
error=0;


if [ $# -lt 1 ]; then
    echo ".........";
    echo "$(basename $0) called without any arguments.  Dying now...";
    echo ".........";
    error=100; exit $error; fi

if [ $# -gt 3 ]; then
    echo ".........";
    echo "$(baesname $0) called without more than 3 arguments." ;
    echo "The inputs are:";
    echo "  Source folder you want to move (required).";
    echo "  Destination folder location (optional-will be ${default_target_disk}/${USER}/data_from_${reverse_target_disk} or /glusterspace, as appropriate).";
    echo "  maximum number of rsync (move) attempts (optional, default 5).";
    echo "Dying now...";
    echo ".........";
    error=100; exit $error; fi


#echo $1;
#if [[ $1  =~ "\s " ]]; then
#    echo "You are testing the ability to handle wildcards"
#    exit 1
#fi

# Lets define error values!
# 1 source not found
# 2 source not a direcrory
# 8 source is smybolic link
# 5 source is not owned by current user
# 4 source, some files not yours
# 3 source and parent not writeable

# 11 source and dest same device 

# 10 dest parent dir not writeable
# 9 dest is symbolic link
# 6 dest parent or name didnt set properly.
# 7 dest dir parent missing, code will only create final dest path, not nested paths.


# 13 rsync transfer failure
# 14 remove failre
# 15 link failure
# 70 its a delete_me folder left over.
# 100 input arg problem

###
# do input cleanup
###

# check if source is abs or rel path, else assume its in current folder.
if [[ ! "${source_folder}" =~ ^/ ]]; then
#    echo "relpath";
    source_folder="${PWD}/${source_folder}";
#else  echo "abspath";
fi

source_folder=`echo ${source_folder} | sed -e 's/[/]*$//'`;   # Strip any trailing slashes.
source_disk=`echo ${source_folder} | awk -F"/" '{print $2}'`; 
source_name=`basename ${source_folder}`; 

if [ ! -z "$target_folder"  ]; then
    target_folder=`echo ${target_folder} | sed -e 's/[/]*$//'`; # Strip any trailing slashes.
fi; 

###
# check on rsync.
###
re='^[0-9]+$';
default_ma=5; # Default number of rsync transfer attempts is 5.
if ! [[ $max_attempts =~ $re ]] || [ "$max_attempts" -lt 1 ]; then
    if [ -z "${max_attempts}" ]; then 
        echo "INFO: Setting max rsync attempts to default value of ${default_ma} attempts.";
    else
        echo "WARNING: An invalid number of max rsync attempts, specified: \"${max_attempts}\"; setting to default of ${default_ma} attempts.";
    fi
    max_attempts=5; # Default number of rsync transfer attempts is 5.
fi 

########################################################################################
# Verify source 
########################################################################################
echo "Transfer Checking ... ${source_folder}";
###
# check source folder type.
###
if [ -L $source_folder ]; then error=8; 
    echo "ERROR: Unsupported behavior: source folder is a symbolic link, which defeats the purpose of this script.";
elif [ -e $source_folder -a ! -d ${source_folder} ]; 
then echo "ERROR: You have specified a non-folder: \"${source_folder}\".";
    error=2; 
elif [ ! -e ${source_folder} ]; 
then echo "ERROR: You have specified a non-existent source folder: \"${source_folder}\"."; 
    error=1; 
fi; 
if [ "$error" -ne 0 ]; then
    exit $error;
fi;

###
# check we're the owner
###
owner=`stat -c '%U' ${source_folder}`;
if [ "$owner" != "$USER" ]; then 
    echo "ERROR: You are NOT the owner of the source folder: \"${source_folder}\".";
    echo "       Only the owner (${owner}) is able to relocate the folder.";
    error=5; exit $error;
fi

###
# Check source folder delete
###
#  ensure's we will be able to remove files when we're done.
if ( ! [ -w "${source_folder}"  -a  -w "${source_folder}/.." ] ); 
then echo "ERROR: You do not have permission to both the source folder \"${source_folder}\" AND its parent directory.";
    error=3;exit $error; fi;

###
# check if its one of our garbage undeleteable files
####
if [[ "${source_name}" =~ ^_DELETE_ME* ]]; 
then echo "ERROR: Blocking access to ${source_folder} in order to avoid an endless cycle of unwanted data propagation.";
    error=70;exit $error; fi;

###
# check the files in source that we'll be able to delete them.
###
undeletable_count=0;
for c_file in `find ${source_folder}/`; do
    if ( ! [ -w ${c_file} ] ); then 
                        #echo "CLOBBY DOBER"
                        # since we've asked to move, clobber write. : )
        chmod u+w ${c_file} && echo "$c_file Set writeable";
    fi;
    if ( ! [ -w ${c_file} ] ); then 
        undeletable_count=$(( $undeletable_count + 1 ));
        echo "...";
        echo "Undeletable file: ${c_file}";
    fi
done
if [[ "${undeletable_count}" -gt 0 ]]; then
  # echo "WARNING: ${undeletable_count} files will not be deleted from source due to permission errors.";
  # echo "          These will need to be manually deleted, and will be found in a _DELETE_ME folder.";
    echo "ERROR:  Found ${undeletable_count} files not owned by you."\
                " They could be moved but not deleted."\
                " This entire folder will be SKIPPED.";
    error=4;exit $error; fi

########################################################################################
# Sort out target
########################################################################################
# If no target folder is specified, then it is assumed you are trying to move data to your directory on /nas4.
# ...unless the source is /nas4, in which case we assume we are moving to /glusterspace.
#
# want to handle swap mode where we say /a/b /d/e and if /a/b is a link, it moves /d/e back to /a/b.
target_parent="";target_name="";
if [ ! -z "$target_folder"  ]; then 
    echo "You smarty specifing your destination location. Reducing error/enforcement on your output.";
    target_disk=`echo ${target_folder} | awk -F"/" '{print $2}'`; 
    target_name=$(basename ${target_folder});
    if [[ "${source_name}" != "${target_name}" ]]; 
    then echo "WARNING:  Not renaming $source_name on the fly to $target_name. $source_name will be in $target_folder/$source_name";
        target_parent="${target_folder}";
        target_name="${source_name}";
    else
        target_parent=`echo ${target_parent} | sed -e "s/${target_name}$//"`;
    fi;
else
# If we dont specify the dest directly use default dest, and we will probably need to create target to get rsync to work right.
    # Set target_disk
    echo -n "    No target folder specified."
    if [[ "${source_disk}" =~ ${default_target_disk} ]]; 
    then target_disk=${reverse_target_disk};
        echo " by default the data will be moved to ${target_disk}."
    else target_disk=${default_target_disk};
        echo " by default the data will be moved to ${USER}'s personal directory on ${target_disk}."
    fi

    user_string=""; bucket="";
    if [[ "$target_disk" =~ ${default_target_disk}  ]];
    then # nas4 disk, need user dir, and bucket.
        echo "    Operating as user: ${USER}";
        user_string="/$USER";
        bucket="/data_from_${source_disk}";
	if [[ ! -d "/${target_disk}${user_string}" ]]; 
	then #echo "Attempting to create a default home for transferred data: \"/${target_disk}${user_string}\"...";
            #echo mkdir -m $PERM_CODE "/${target_disk}${user_string}";
	    echo "ERROR:  User storage space missing! Please ask IT staff to give user storage space on /${target_disk}${user_string}";
	    error=7; exit $error; fi
	
	target_parent="/${target_disk}${user_string}${bucket}";
	if [[ ! -d ${target_parent} ]];
	then echo "Missing target parent folder \"${target_parent}\", attempting to create...";
	    mkdir -m $PERM_CODE ${target_parent};
	fi
    else 
	target_parent="/${target_disk}";
    fi;
    target_name="${source_name}";
fi;
target_folder="${target_parent}/${target_name}";# target_name should always equal source_name at this point.

if [ -z "$target_parent" -o -z "$target_folder" ]; 
then echo "ERROR:  Could not set target_parent or target_folder properly";
    error=6; exit $error; fi;

if [[ ! -d ${target_parent} ]]; 
then echo "ERROR:  Missing target parent: \"${target_parent}\". Did you mean to create it?"
    error=7; exit $error; fi
#echo "target parent = ${target_parent}";

if [[ -L "${source_folder}" ]]; then
# this'll never run becuase we check for link earlier... I think thats fine. 
    true_source=`readlink ${source_folder}`;
    true_source=`echo ${true_source} | sed -e 's/[/]*$//'`; # Strip any trailing slashes
    if [[ "${true_source}" = "${target_folder}" ]]; then
        echo "............";
        echo "It appears that this script has ran successfully on a previous occassion (i.e. the source folder is a symbolic link pointing at the target folder).";
        echo "No work will be done; exiting script with success code 0.";
        echo "............";
        echo "Success! ${source_folder} now symbolically points to ${target_folder}, the true home of your data."
        echo "Goodbye.";
        exit 0;
    else
        echo "............";
        echo "ERROR: Unsupported behavior: source folder is a symbolic link, which defeats the purpose of this script.";
        echo "       For your reference, the implied home of the source data is: \"${true_source}\".";
        error=8;
    fi
fi

if [[ -L "${target_folder}" ]]; then
    true_target=`readlink ${target_folder}`;
    true_target=`echo ${true_target} | sed -e 's/[/]*$//'`; # Strip any trailing slashes.
    if [[ "${true_target}" = "${source_folder}" ]]; then
        echo "............";
        echo "The target folder exists as a symbolic link pointing back to the source folder; deleting this symbolic link.";
        rm ${target_folder};
    else
        echo "............";
        echo "ERROR: Unsupported behavior: a symbolic link has been specified as the target, pointing to: \"${true_target}\".";
        error=9;
    fi
elif [ ! -w "${target_parent}" ]; then
    echo "............";
    echo "ERROR: You do not have permission to write to create a folder in the parent directory of the target: \"${target_parent}\".";
    error=10;
fi

# Source and target now set.

if [ $error -ne 0 ]; then
    echo "Fatal error detected; quitting program without doing any work.";
    exit $error;
fi

#
# check if same device. Do not allow that.
#
source_test=`stat -c "%d" ${source_folder}`;
target_test=`stat -c "%d" ${target_parent}`;
if [[ "${source_test}" = "${target_test}" ]]; then
    echo "............";
    echo "ERROR: You are attempting to relocate data within the same device; "\
                 "Instead plaease: \"mv\" $source_folder $target_folder ";
    echo "    Dying now...";
    error=11;
    exit $error;
    #echo "mv ${source_folder} ${target_parent}/";
fi;

########################################################################################
# rsync transfer and rm -fr source!
########################################################################################
counter=0
rsync_exit_code=1

start_time=`date`;
SECONDS=0;
echo "...........";
#echo '\/\/\/\/\/\/\/\/\/\/';
echo "Transferring folder \"${source_name}\" from ${source_disk} to ${target_disk}.";
echo "Transfer started at ${start_time}.";

for  (( counter=1; counter<=$max_attempts; counter=$[$counter+1] )); do
    if [[ $rsync_exit_code -ge 1 ]]; then
        echo "    attempt number: $counter";
        cmd="rsync -avh  ${source_folder} ${target_parent}";
        echo $cmd
        $cmd
        rsync_exit_code=$?;
    fi
done

echo "...........";
end_time=`date`;
end_time_seconds=$(date +%s);
elapsed_time=$SECONDS;

echo "Transfer ended at ${end_time}.";

if [[ $rsync_exit_code -ge 1 || ! -d ${target_folder} ]]; then
    echo "";
    echo "ERROR:  rsync failed attempting to transfer data to ${target_disk}.";
    if [ -d ${target_folder} ] ; then 
        echo "        The partial transfer has NOT been deleted.";
        echo "";
        echo "        Please check both your source and destination.";
        echo "        source:      \"$source_folder\" ";
        echo "        destination: \"${target_folder}\" ";
        echo "        It is PROBABLY safe to remove the destination using rm -fr ${target_folder};";
    fi;
    sleep 2; 
    error=13; exit $error; fi;


echo "Total elapsed time: ${elapsed_time} seconds.";
echo "...........";
#echo '/\/\/\/\/\/\/\/\/\/\';

###
# try to remove
###
rm_status=0;
if [ -d ${target_folder} ]; then
    cmd="rm -rf ${source_folder}";
    echo $cmd;
    $cmd;
    rm_status=$?;
fi;


###
# try to link
###
if [[ "${undeletable_count}" -gt 0 || $rm_status -gt 0 ]]; then 
    source_parent=`echo ${source_folder} | sed -e "s/${source_name}$//"`;
    delete_me_folder="${source_parent}_DELETE_ME_${source_name}";
    echo "$source_parent:$delete_me_folder";
    if [[ ! -e "${delete_me_folder}" ]];then
        mkdir -m 777 ${delete_me_folder};
    fi
    echo "............";
    echo "Attempting to move ${undeletable_count} undeletable files to ${delete_me_folder} for manual removal at a later date."
    mv -f ${source_folder} ${delete_me_folder};
fi

ln -sT ${target_folder} ${source_folder};
ln_return_code=$?;

echo "ln return code is: $ln_return_code";
if [[ "${ln_return_code}" -gt 0 ]]; then
    echo $source_folder;
    echo $source_parent;
    echo "............";
    echo "PARTIAL SUCCESS: contents of \"${source_name}\" were completely transferred to \"${target_parent}\"."
    echo "HOWEVER, some children folders and/or files could not be removed." #belonged to a different owner, and
    echo "Thus,a symbolic link could NOT be created to point from the original location to the target location."
    echo "Please ask your local IT guy/gal for further guidance."
    echo "Goodbye."
    exit 1;
else
    echo "............";
    echo "Success! ${source_folder} now symbolically points to ${target_folder}, the true home of your data."
    if [[ "${undeletable_count}" -gt 0 ]]; then
        echo "PLEASE NOTE: DELETE_ME folder was generated and will need to be manually removed by your local IT support person."
        echo "This folder is: ${delete_me_folder}.";
    fi
    echo "Goodbye.";
    echo "";
    exit 0;
fi
