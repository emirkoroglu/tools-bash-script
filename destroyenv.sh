#!bin/bash

rs=`tput sgr0`    # reset
g=`tput setaf 2`  # green
y=`tput setaf 3`  # yellow
r=`tput setaf 1`  # red
b=`tput bold`     # bold
u=`tput smul`     # underline
nu=`tput rmul`    # no-underline


echo ${g}"Please enter the tmp folder location"${rs}
read tmp_folder
cd $tmp_folder
cat main.yml | grep -E 'env_name|cloud|aws_region|env_deathdate'
echo ${r}"Please type y if the above information is correct and you want to destroy $env_name environment"${rs}
read answer
if [ $answer == "y" ]; then
    echo ${y}"Destroying environment $envname starting"${rs}
    terragrunt plan-all -destroy
    echo ${b}"If you see any error related to provider please type r to replace the provider in reporting and dgc folder"${rs}
    read answer
    if [ $answer == "r" ]; then
        echo "Replacing provider, Please wait..."
        cd reporting/
        terragrunt state replace-provider 'registry.terraform.io/-/aws' 'registry.terraform.io/hashicorp/aws'
        terragrunt init
        terragrunt state replace-provider registry.terraform.io/-/template registry.terraform.io/hashicorp/template
        terragrunt init
        cd ..
        cd dgc
        terragrunt state replace-provider 'registry.terraform.io/-/aws' 'registry.terraform.io/hashicorp/aws'
        terragrunt init
        terragrunt state replace-provider registry.terraform.io/-/template registry.terraform.io/hashicorp/template
        terragrunt init
        echo "Provider replaced returning to tmp folder"
        cd ..
        terragrunt plan-all -destroy
        echo "If you do not see any issues please type y to destroy the environment"
        read answer
        if [ $answer == "y" ]; then
            echo ${g}"Destroying environment $envname starting"${rs}
            terragrunt destroy-all
        else
            echo ${y}"Aborting"${rs}
        fi
    else
        echo ${y}"Destroy Operation cancelled"${rs}
    fi
else
    echo ${y}"Destroy Operation Cancelled"${rs}
fi