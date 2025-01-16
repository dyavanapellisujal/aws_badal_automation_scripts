#!/bin/python3

import subprocess
import json
import sys

command = [
    'aws', 's3api', 'list-objects-v2',
    '--bucket', sys.argv[1],
    '--output', 'json'
]


i = 0
file_names = []  #Collect file names

try:

    result = subprocess.run(command, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

    data = json.loads(result.stdout)


    if 'Contents' in data:
        for item in data['Contents']:
            file_names.append(f'"{item["Key"]}"')  
            i += 1
    else:
        print("No objects found in the bucket.")

    print(",".join(file_names))

    # If there are any errors in the command's stderr
    if result.stderr:
        print("Error:")
        print(result.stderr)

except subprocess.CalledProcessError as e:
    print(f"Command failed with error: {e}")
