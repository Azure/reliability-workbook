# Reliability Workbook

This workbook focus on the Reliability pillar of the Azure Well-Architected Framework and provides insights into the reliability aspects deployed in Azure subscriptions.

## Deploy workbooks

This Reliability Workbook consists of several co-workbooks. For easy deployment, you can use the deployment tool. For more information about using this tool, see below.

### Pre-requisites

- This tool needs to run on Linux, WSL, or Azure Cloud Shell. You cannot use a Windows environment.
  - [Azure Cloud Shell](https://learn.microsoft.com/en-us/azure/cloud-shell/quickstart?tabs=azurecli) is currently recommended for easy deployment.
- If you don't run this tool in Azure Cloud Shell, you may need to install the following tools:
  - Install Azure CLI. See [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).
  - Install `wget` command-line tool. If not installed, you can install it using the package manager for your Linux distribution (e.g., `apt-get install wget` for Debian/Ubuntu or `yum install wget` for CentOS/RHEL).
- User needs to have at least [Workbook Contributor](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#workbook-contributor) access to import the workbook and [Monitoring Reader](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#monitoring-reader) to have access to monitoring information.
  - If you would like to create Resource Group when no Resource Group exists, the user must have permission access to create Resource Group.

### Deploy steps

1. Create directory to run the script.
    ```shell
    mkdir deploy-workbook
    ```
1. Download the scripts provided in the `script` folder in this repository.
    ```shell
    wget https://raw.githubusercontent.com/Azure/reliability-workbook/main/scripts/deploy-workbook.sh
    ```
1. Make the script executable.
    ```shell
    chmod +x deploy-workbook.sh
    ```
1. Run the script with the required parameters.

    Usage:

    ```shell
    $ ./deploy-workbook.sh 
    Usage: ./deploy-workbook.sh -s <Subscription ID> -g <Resource Group> [-t <Tenant ID>] [-c Create Resource Group if not exist] [-l <location>] [-b <Base URL of Workbook>] [-d]
    Example 1: When you want to deploy workbook to resource group myResourceGroup in subscription
            ./deploy-workbook.sh -s 00000000-0000-0000-0000-000000000000 -g myResourceGroup -t 00000000-0000-0000-0000-000000000000
    Example 2: When you want to deploy workbook to resource group myResourceGroup in subscription and create resource group if not exist
            ./deploy-workbook.sh -s 00000000-0000-0000-0000-000000000000 -g myResourceGroup -t 00000000-0000-0000-0000-000000000000 -c -l japaneast
    ```

    If you want to deploy the workbook to an existing Resource Group, you can use the following command:

    ```shell
    ./deploy-workbook.sh -s 00000000-0000-0000-0000-000000000000 -g myResourceGroup
    ```

    If you want to create a new Resource Group, you can use the `-c` parameter with `-l <location>`:  

    ```shell
    ./deploy-workbook.sh -s 00000000-0000-0000-0000-000000000000 -g myResourceGroup -c -l japaneast
    ```

    If there are any issues with the deployment script, review the `deploy-workbook.sh` script in `scripts/deploy-workbook.sh` for any errors or misconfigurations.

### Deploy only Export Workbook easily

If you only want to deploy the Export workbook, you can deploy from the following button.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Freliability-workbook%2Fmain%2Fworkbooks%2Fazuredeploy_export.json)

## FAQ

### Deploy steps

#### How to specify a tenant ID?

If you have access to many tenants, az command may take a long time. To prevent this behavior, you may want to specify tenant ID with `-t` option.

```shell
./deploy-workbook.sh -s 00000000-0000-0000-0000-000000000000 -g myResourceGroup -t 00000000-0000-0000-0000-000000000000 -c -l japaneast
```

#### I got a syntax error after deploying and opening the Workbook. How do I fix it?

You may be using Windows environment like Git Bash. If you are running on this script in Windows, there may be something wrong with the newline characters.
In this case, please try in Azure Cloud Shell, WSL or pure Linux environment.

#### Can I deploy from local Workbook files?

Yes, you can deploy from local Workbook files.

If you want to deploy the workbook files from your current directory, you can use the -b option with a dot (.).
This will deploy all *.workbook files in the current directory. This option is useful when you want to test your workbooks in a development environment.

Here is how you can do it:

```bash
cd workbooks
../scripts/deploy-workbook.sh -s 00000000-0000-0000-0000-000000000000 -g myResourceGroup -c -l japaneast -b .
```

Note: Change to the directory where your workbooks are located. This isn't necessary if the workbooks are in the same directory as the script, as is the case if you are just downloading the script.

### Workbook

#### Why is the disk information not available?

VMs have to be running for disk information to be available.

### Deploy test environment

#### How do I deploy a test environment?

If you want to create a test environment to test this workbook, you need to deploy Azure resources to your subscription.
To do this, we have prepared Terraform code in the `build/test_environment` folder.
This directory is completely separated from the `build` directory in terms of Terraform.
In other words, you need to initialize the Terraform environment separately in the `build/test_environment` directory.

> [!NOTE]
> As it is still a work in progress, this test code may not yet contain the code to deploy all testing resources.

You can create a test environment with the following steps.

> [!NOTE]
> Please refer to `variables.tf` and override the variables as needed.

```shell
cd test_environment
terraform init
terraform plan -out plan.out
terraform apply plan.out
```


## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
