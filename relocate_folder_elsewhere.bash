#!/bin/bash
# Run the relocate code for a list of folders.(can use * to get them all)
source_folders=$1;
target_folder=$2;
max_attempts=$3;

#user=`whoami`;# This is a system provided variable( in all caps). 
# Check for existing variaobles using "env" or the more comprehensive "set" command. 

#echo $1;

SECONDS=0;
cumulative_status=0;
for source_folder in $(echo $source_folders | tr " " "\n"); do
    for current_folder in $source_folder; do
        base_source=`basename ${current_folder}`;
        if [[ "${base_source}" =~ ^_DELETE_ME* ]]; then
            echo "Skipping _DELETE_ME folder: ${current_folder}..."
        else
            cmd="/cm/shared/workstation_code_dev/shared/civm_bash_utils/relocate_folder_elsewhere_core.bash ${current_folder} ${target_folder} ${max_attempts}";
            echo $cmd;
            #status_code=`${cmd}`; # this stores the result of the program in status_code, not the program return code. 
            #echo `${cmd}`; #This destroys the return code, and substittues the return value for echo, which will work.
            ${cmd}; # prefered was to run code in shell. 
            status_code=$?;
            if [[ "${status_code}" -gt 0 ]]; then
                echo "Unable to relocate folder: ${current_folder}.";
                let cumulative_status=$cumulative_status+$status_code;
            else
                echo "Successfully relocated folder: ${current_folder}";
            fi
        fi
        echo "........................................";
    done
done

echo "Total elapsed time = ${SECONDS} seconds.";

if [ $cumulative_status -gt 0 ] ;then
    echo "Sorry, ${USER}! We had some errors. Please read carefully above about those folders.";
else
    echo "Great job, ${USER}!";
fi;
exit 0;
