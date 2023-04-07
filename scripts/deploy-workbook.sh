#!/bin/sh

# Return current date and time with passed log message
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $1" | tee -a log
}

# Get user input
prompt() {
    varname=$1
    optional=$3
    read_str=
    while :
    do
        echo -n "$2"
        read read_str
        if [ x$read_str = x"" -a x$optional = x"" ]; then
            continue
        else
            break
        fi
    done
    eval "$varname=$read_str"
}

# Get target subscription from user input
prompt subscription_id "Enter target Subscription ID: "

# Get target resource group from user input
prompt resource_group_name "Enter target Resource Group name: "

# If this script doesn't run on CloudShell, it will execute login to Azure
if [ x$ACC_CLOUD = x"" ]; then
  # Get tenant from user input
  prompt tenant "Enter target Tenant name(optional): " this-is-option
  [ x$tenant != x"" ] && tenant="-t $tenant"

  # az login
  log "Login to Azure"
  az login $tenant --use-device-code
fi

log "Check existance of target resource group"
az group show --name $resource_group_name --subscription $subscription_id
if [ $? -ne 0 ]; then
    log "Please input correct SubscriptionID and Resource Group name"
    exit 1
fi

base_url="https://raw.githubusercontent.com/Azure/reliability-workbook/main/"
# Download file list
[ ! -f workbook_filelist ] && wget $base_url/artifacts/workbook_filelist
cat workbook_filelist | while read f
do
    log "Download workbook file: $f"
    if [ -f $f ]; then
        log "Skip download because the file already exists"
    else
        wget $base_url/artifacts/$f
    fi
done

# Deploy Workbook
for f in *.workbook
do
  filename_base=`basename $f .workbook`
  filename=`basename $f`
  file_size=$(stat -c%s "$f")
  if [ ! -e ${filename_base}_id -o $file_size -eq 0 ]; then
    log "Deploy ${filename_base}"
    { az deployment group create --name $filename_base -g $resource_group_name --template-uri $base_url/artifacts/azuredeploy.json --parameters serializedData=@$filename --parameters name=$filename_base --query 'properties.outputs.resource_id.value' -o json; } > ${filename_base}_id &
  fi
done

# Wait for all deployment processes
wait

[ ! -e workbook.tpl.json ] && wget $base_url/build/templates/workbook.tpl.json
for f in *_id
do
    resource_id=`cat $f | tr -d '\"'`
    # Get resource type from filename (e.g.: ReliabilityWorkbookExport.workbook -> export)
    resource_type=`echo $f | sed -e 's/.*Workbook\([^.]*\).*_id/\L\1/g'`
    # Replace placeholder in the file
    sed -i "s#\\\${${resource_type}_workbook_resource_id}#$resource_id#g" workbook.tpl.json
done

overview_information=$(cat <<EOS
          ,{
            "type": 1,
            "content": {
              "json": "* This workbook source is maintained publicly as OpenSource in [GitHub Repository](https://github.com/Azure/reliability-workbook). There is no Service Level guarantees or warranties associated with the usage of this workbook. Refer [license](https://github.com/Azure/reliability-workbook/blob/main/LICENSE) for more details.\r\n\r\n> If there are any bugs or suggestions for improvements, feel free to raise an issue in the above GitHub repository. In case you want to reach out to maintainers, please email to [FTA Reliability vTeam](mailto:fta-reliability-team@microsoft.com)",
              "style": "info"
            },
            "name": "text - 3"
          }
EOS
)

escaped_replacement_text=$(printf '%s\n' "$overview_information" | sed 's:[\/&]:\\&:g;$!s/$/\\/')
sed -i "s/\${overview_information}/$escaped_replacement_text/g" workbook.tpl.json

link_of_Summary=$(cat <<EOS
          ,{
            "id": "d6656d8e-acfc-4d7d-853d-a8c628907ba6",
            "cellValue": "selectedTab",
            "linkTarget": "parameter",
            "linkLabel": "Summary",
            "subTarget": "Summary2",
            "style": "link"
          }
EOS
)
escaped_replacement_text=$(printf '%s\n' "$link_of_Summary" | sed 's:[\/&]:\\&:g;$!s/$/\\/')
sed -i "s/\${link_of_Summary}/$escaped_replacement_text/g" workbook.tpl.json

summary_id=$(cat ReliabilityWorkbookSummary_id | tr -d '\"')
tab_of_Summary=$(cat <<EOS
    ,{
      "type": 12,
      "content": {
        "version": "NotebookGroup/1.0",
        "groupType": "template",
        "loadFromTemplateId": "${summary_id}",
        "items": []
      },
      "conditionalVisibility": {
        "parameterName": "selectedTab",
        "comparison": "isEqualTo",
        "value": "Summary2"
      },
      "name": "summary group"
    }
EOS
)
escaped_replacement_text=$(printf '%s\n' "$tab_of_Summary" | sed 's:[\/&]:\\&:g;$!s/$/\\/')
sed -i "s/\${tab_of_Summary}/$escaped_replacement_text/g" workbook.tpl.json


link_of_Advisor=$(cat <<EOS
         ,{
            "id": "d983c7c7-b5a0-4245-86fa-52ac1266fb13",
            "cellValue": "selectedTab",
            "linkTarget": "parameter",
            "linkLabel": "Azure Advisor",
            "subTarget": "Advisor",
            "style": "link"
          }
EOS
)
escaped_replacement_text=$(printf '%s\n' "$link_of_Advisor" | sed 's:[\/&]:\\&:g;$!s/$/\\/')
sed -i "s/\${link_of_Advisor}/$escaped_replacement_text/g" workbook.tpl.json

advisor_id=$(cat ReliabilityWorkbookAdvisor_id | tr -d '\"')
tab_of_Advisor=$(cat <<EOS
    ,{
      "type": 12,
      "content": {
        "version": "NotebookGroup/1.0",
        "groupType": "template",
        "loadFromTemplateId": "${advisor_id}",
        "items": []
      },
      "conditionalVisibility": {
        "parameterName": "selectedTab",
        "comparison": "isEqualTo",
        "value": "Advisor"
      },
      "name": "Advisor"
    }
EOS
)
escaped_replacement_text=$(printf '%s\n' "$tab_of_Advisor" | sed 's:[\/&]:\\&:g;$!s/$/\\/')
sed -i "s/\${tab_of_Advisor}/$escaped_replacement_text/g" workbook.tpl.json

link_of_Export=$(cat <<EOS
          ,{
            "id": "0f548bfa-f959-4a25-a9ac-7c986be6d33b",
            "cellValue": "selectedTab",
            "linkTarget": "parameter",
            "linkLabel": "Export",
            "subTarget": "Export",
            "style": "link"
          }
EOS
)
escaped_replacement_text=$(printf '%s\n' "$link_of_Export" | sed 's:[\/&]:\\&:g;$!s/$/\\/')
sed -i "s/\${link_of_Export}/$escaped_replacement_text/g" workbook.tpl.json

export_id=$(cat ReliabilityWorkbookExport_id | tr -d '\"')
tab_of_Export=$(cat <<EOS
    ,{
      "type": 12,
      "content": {
        "version": "NotebookGroup/1.0",
        "groupType": "template",
        "loadFromTemplateId": "${export_id}",
        "items": []
      },
      "conditionalVisibility": {
        "parameterName": "selectedTab",
        "comparison": "isEqualTo",
        "value": "Export"
      },
      "name": "ExportStep"
    }
EOS
)
escaped_replacement_text=$(printf '%s\n' "$tab_of_Export" | sed 's:[\/&]:\\&:g;$!s/$/\\/')
sed -i "s/\${tab_of_Export}/$escaped_replacement_text/g" workbook.tpl.json

log "Deploy FTA - Reliability Workbook"
az deployment group create -g $resource_group_name --template-uri $base_url/artifacts/azuredeploy.json --parameters name="FTA - Reliability Workbook" serializedData=@workbook.tpl.json
