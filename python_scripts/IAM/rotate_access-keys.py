import csv
import boto3 
import datetime
import sys
import pandas as pd 
def run_audit(rotate):
    
    current_time=datetime.datetime.now()
    client=boto3.client('iam')

    response=client.get_paginator('list_users')
    users_list=[]
    for page in response.paginate():
        current_user = page['Users']
        
        
        for j in range(0,len(current_user)):
            current_iam_user=current_user[j]
            username=current_iam_user['UserName']
            
            get_access_key_status = client.list_access_keys(UserName=username)
            
            access_key_metadata=get_access_key_status['AccessKeyMetadata']
            
            if len(access_key_metadata)>0:
                
                for i in access_key_metadata:
                    
                    createdate=i['CreateDate']
                    access_key_id=i['AccessKeyId']
                    current_time=current_time.replace(tzinfo=createdate.tzinfo)
                    diff=current_time-createdate
                    print(username)
                    days=diff.days
                    print(days)
                    if days>=15:

                        temp_dict={"IAM_USER":username,"Days":days}
                        users_list.append(temp_dict)
                        print(username)
                    
                        if rotate==True:
                            response = client.delete_access_key(UserName=username,AccessKeyId=access_key_id)
                            response = client.create_access_key(UserName=username)
                            print(response)
                            # print("rotating keys")

                        elif rotate==False:

                                    

                                        
                                        
                            try:
                                    
                                    print("Creating a csv file with IAM-Users having access-keys over 15 days")
                                    csv_file='iam-access-key-audit.csv'
                                    with open(csv_file,'w',newline="") as csvfile:
                                        fieldnames = ['IAM_USER', "Days"]
                                        write_csv = csv.DictWriter(csvfile,fieldnames=fieldnames)
                                        write_csv.writeheader()
                                        write_csv.writerows(users_list)
                
                
                
                
        
                            except Exception as e:
                                print(e)



if __name__=='__main__':
    if len(sys.argv) == 2:
        for arg in range(1,len(sys.argv)):
            
            if sys.argv[1].startswith('--rotate') and len(sys.argv)==2:
                
                print("--rotate selected")
                run_audit(rotate=True)
            elif sys.argv[1].startswith('--audit') and len(sys.argv)==2:
                
                print("--audit selected")
                run_audit(rotate=False)
                print("--audit selected")
    elif len(sys.argv)>2:
        print("You can either rotate or audit the IAM_ACCESS_KEYS")
                
        
                
    elif len(sys.argv)<2:
        print("Please provide a flag to rotate (--rotate) or a output file(--audit)")

# print(users_list)