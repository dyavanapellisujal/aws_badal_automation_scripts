#!/bin/bash


function create_subnet {

    
    read -p "Provide the cidr block for this subnet: " cidr_block_for_subnet
    
    read -p "Provide the name(tag) for this subnet: " subnet_tag
    subnet_id=$(aws ec2 create-subnet --vpc-id $vpcid --cidr-block $cidr_block_for_subnet --tag-specifications "ResourceType=subnet,Tags=[{Key=Name,Value=$subnet_tag}]" --query Subnet.SubnetId --output text)  
    echo "Creating route-table with tag $tagvpc$subnet_tag"rt""
    routetag=$tagvpc$subnet_tag"rt"
    route_table_id=$(aws ec2 create-route-table --vpc-id $vpcid --tag-specifications "ResourceType=route-table,Tags=[{Key=Name,Value=$routetag}]" --query RouteTable.RouteTableId --output text)
    if [[ $1 == "True" ]];
    then
        add_publicroute_associate=$(aws ec2 create-route --destination-cidr 0.0.0.0/0 --gateway-id $igwid --route-table-id $route_table_id && aws ec2 associate-route-table --subnet-id $subnet_id  --route-table-id $route_table_id)
        if [[ -n $add_publicroute_associate ]];

        then
            
            echo "Subnet with internet access created!"
        else   
            echo "Couldn't attach the route table with tag $routetag with this subnet"
        fi 
    
    else
        associate_route=$(aws ec2 associate-route-table --subnet-id $subnet_id --route-table-id $route_table_id)
        if [[ -n $associate_route ]];
        then
            echo "Private subnet created"
        else
            echo "Couldn't attach the route table with tag $routetag with this subnet"
        fi
    fi
}
#create a vpc first 

read -p "Provide the cidr block: " cidrblock
read -p "Provide the region: " region

echo "Provide the name(tag) to identify the VPC: "
read tagvpc

igwtag=$tagvpc"igw"
vpcid=$(aws ec2 create-vpc --cidr-block $cidrblock --region $region --tag-specifications "ResourceType=vpc,Tags=[{Key=Name,Value=$tagvpc}]" --query Vpc.VpcId --output text)





#create and attach a internet gateway to the vpc


igwid=$(aws ec2 create-internet-gateway --tag-specifications "ResourceType=internet-gateway,Tags=[{Key=Name,Value=$igwtag}]" --query InternetGateway.InternetGatewayId --output text)
echo $vpcid
echo $igwid 

echo "Attaching the internet-gateway $igwid with tag $igwtag to vpc $vpcid"
aws ec2 attach-internet-gateway --internet-gateway-id "$igwid" --vpc-id "$vpcid" 
 

read  -p "Create a subnet in this vpc?(y/n)" subnetprompt

if [[ ${subnetprompt,,} == "y" ]];
then    
    while true;
    do
        echo -e  "1.Public Subnet \n 2.Private Subnet \n 3.Both"
        read subnet_type
        if [[ $subnet_type -eq 1 ]];
        then 
                echo "Creating public subnet"
                create_subnet "True"
        elif [[ $subnet_type -eq 2 ]];
        then
                echo "Creating private subnet"
                create_subnet
        elif [[ $subnet_type -eq 3 ]];
        then 
                echo "Creating public subnet"
                create_subnet "True"
                echo "Creating private subnet"
                create_subnet 
        fi

        echo 
        read -p "Create more subnets?(y/n)" more_subnet
        if [[ ${more_subnet,,} == "n" ]];
        then
                break
        fi

    done  
fi
                
                

