# aws_cloud_automation_scripts
This repository includes scripts for automating tasks in the aws cloud environment


1.mfa-status.py
This script is to check the mfa status for all the IAM users. It creates a csv file
You can create a excel file if you want once the csv is created by entering "y". 


Downloading the script and using it
Step 1: Clone the repository and download the dependencies (before installing the dependencies, make sure to create a virtual environment)

```bash
git clone https://github.com/dyavanapellisujal/aws_cloud_automation_scripts.git & cd aws_cloud_automation_scripts &  pip install -r requiements.txt 
```
Step 2: Run the script along the csv file name
```bash
python3 mfa-status.py "new.csv"
```
![image](https://github.com/user-attachments/assets/f7240b11-288a-4585-9578-dbf6a5ab5eca)

If you select "Y" for the script , this will create a excel for the csv file.(Not mandatory , because you can import the csv file into the excel sheet viewer tools).



![image](https://github.com/user-attachments/assets/ab414d23-e731-4e7a-9bf2-cbb8a363f9ac)



