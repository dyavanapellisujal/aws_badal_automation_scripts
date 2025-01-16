#!/bin/bash

bucket_name=$1
if [ -z $bucket_name ];
then
        echo "Current Buckets:"
        bucket_name=$(aws s3api list-buckets --query Buckets[].Name | jq -r '.[]')
        j=0
        for i in $bucket_name;
        do
                echo $j"."$i
                ((j++))
        done

	echo "Provide the bucket number you wish to delete"
	read bucket_number
	bucket_name=( $bucket_name )
	cmd=$(aws s3api delete-bucket --bucket "${bucket_name[$bucket_number]}" 2>&1)
	if [ $? -ne 0 ];
        then

               if [[ "$cmd" == *"The bucket you tried to delete is not empty"* ]];
               then
                        echo "Error: ${bucket_name[$bucket_number]} bucket is not empty"
                        echo "Listing objects in ${bucket_name[$bucket_number]}"

			selected_bucket="${bucket_name[$bucket_number]}"

			objects=$(python3 ./supporting_scripts/list_objects.py $selected_bucket)
                        o=0
			IFS=','
                        for object in $(echo "$objects");
                        do
                                echo  "$o.$object"
                                ((o++))
                        done
                        echo -e "\nDo you want to empty the bucket?(y/n):"
                        read to_delete
                        if [[ "$to_delete" == *"y"* ]];
                        then
				echo "Deleting objects from ${bucket_name[$bucket_number]}"
                                IFS=','
				for object in $(echo "$objects");
				do
					object=$(echo "$object" | xargs | sed 's/^"\(.*\)"$/\1/')
					echo "Current object : $object"
					aws s3api delete-object --bucket $selected_bucket --key "$object"
				done
				unset IFS
				echo -e "Objects deleted successfully \n Deleting ${bucket_name[$bucket_number]}"
                                aws s3api delete-bucket --bucket $selected_bucket 
                                echo "Successfully Deleted: ${bucket_name[$bucket_number]}"
                       


                        else
                                echo "Okay!! Bye :)"
                        fi
		fi
	fi




else
        cmd=$(aws s3api delete-bucket --bucket $bucket_name 2>&1)

        if [ $? -ne 0 ];
        then

		if [[ "$cmd" == *"The bucket you tried to delete is not empty"* ]];
		then
			echo "Error: $bucket_name bucket is not empty"
			echo "Listing objects in $bucket_name"
			objects=$(python3 ./supporting_scripts/list_objects.py $bucket_name)
			o=0
			IFS=','
			for object in $(echo "$objects");
			do
				echo $o"."$object
				((o++))
			done
			echo -e "\nDo you want to empty the bucket?(y/n):"
			read to_delete
			if [[ "$to_delete" == *"y"* ]];
			then
				echo "Deleting objects from $bucket_name"
				IFS=','
                                for object in $(echo "$objects");
                                do
                                        object=$(echo "$object" | xargs | sed 's/^"\(.*\)"$/\1/')
                                        echo "Deleting : $object"
                                        aws s3api delete-object --bucket $bucket_name --key "$object"
                                done
                                unset IFS


				echo -e "Objects deleted successfully\n Deleting $bucket_name"
				aws s3api delete-bucket --bucket $bucket_name
				echo "Successfully Deleted: $bucket_name"
			else
				echo "Okay!! Bye :)"
			fi

		fi
        else
                echo "Success:" $bucket_name "was successfully deleted"
        fi
fi

