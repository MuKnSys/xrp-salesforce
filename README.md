# XRP-Salesforce Project

This is a basic demonstration Salesforce DX Project. Using the [SF CLI](https://developer.salesforce.com/tools/sfdxcli) tools, you can deploy to a Developer Edition Scratch Org.

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## Salesforce Developer Edition

You can get a free Salesforce Developer Edition account from Salesforce. Sign up at:

https://developer.salesforce.com/signup

## How To Test the App

1. Checkout the Main Branch
1. Create a scratch org by running `sf org create scratch -f ./config/project-scratch-def.json -a dev -d -y 30`
    - flag `-f` is a path to config file (no need to change it)
    - flag `-a` is an alias of the scratch org, if you create multiple scratch orgs you can give them unique aliases to easier refer to them
    - flag `-d` marks the newly created scratch org as default. If you don't mark it as default you will have to reference it by username or alias, or you will have to use `sf config set target-org YourAliasOrUsername` to set is as default
    - flag `-y` sets the number of days before org expires
    - use `-h` flag for help
    - For more details: [developer docs scratch orgs create](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_scratch_orgs_create.htm)
1. Push the code to the Scratch Org: `sf project deploy start`
1. Connect to the Salesforce Scratch Org `sf org open`

## Submitting changes to GitHub

1. Create a feature / change branch - you will need to fork the project
1. Pull changes from Salesforce `sf project retrieve start`
1. Push changes to GitHub
1. Create a pull request


## Notes - Convert these to sfdx
sfdx force:org:create -f config/project-scratch-def.json --setalias xrpsalesforce1 --durationdays 30 --setdefaultusername --json --loglevel fatal
