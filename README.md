# XRP-Salesforce Project

This is a basic demonstration Salesforce DX Project. Using the [SF CLI](https://developer.salesforce.com/tools/sfdxcli) tools, you can deploy to a Developer Edition Scratch Org.

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## Salesforce Developer Edition

You can get a free Salesforce Developer Edition account from Salesforce. Sign up at:

https://developer.salesforce.com/signup

## How To Test the App - Unlocked Package v1.0.0
1. Install the app using one of these links:
    - https://login.salesforce.com/packaging/installPackage.apexp?p0=04tTO0000001d8zYAA - Production
    - https://test.salesforce.com/packaging/installPackage.apexp?p0=04tTO0000001d8zYAA - Sandbox

## How To Test the App - Using Repository

1. Checkout the Main Branch
1. Log into the Dev Hub Org by running `sf org login web --set-default-dev-hub --alias DevHub --instance-url https://login.salesforce.com` and entering your username and password.
1. Create a Scratch Org by running `sf org create scratch -f ./config/project-scratch-def.json -a dev -d -y 30`.
    - The `-f` flag is a path to config file (no need to change it).
    - The `-a` flag is an alias of the scratch org, if you create multiple scratch orgs you can give them unique aliases to easier refer to them.
    - The `-d` flag marks the newly created scratch org as default. If you don't mark it as default you will have to reference it by username or alias, or you will have to use `sf config set target-org YourAliasOrUsername` to set is as default.
    - The `-y` flag sets the number of days before the org expires.
    - Use the `-h` flag for help.
    - For more details: [developer docs scratch orgs create](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_scratch_orgs_create.htm).
1. Push the code to the Scratch Org: `sf project deploy start`
1. Connect to the Salesforce Scratch Org: `sf org open`

Once you've set up your Salesforce Scratch Org, you can follow the steps outlined in our [user manual](https://mukn.com/wp-content/uploads/2023/07/Web3-Enabler-for-Salesforce-User-Guide.pdf) to make and receive payments using Web3 Enabler on Salesforce. You can also use our [demo](https://www.youtube.com/watch?v=lkAp2vqQVTA) as a guide.  

We launched Web3 Enabler on the Salesforce App Exchange in July, 2023.  See our [AppExchange listing](https://appexchange.salesforce.com/appxListingDetail?listingId=ee4c011b-7a5b-4a50-91fb-f28049390858) for further details.

## User/Admin Story Documentation
User Guide: [XRP for Salesforce User Guide](https://github.com/MuKnSys/xrp-salesforce/blob/main/Documentation%20and%20Images/Web3%20Enabler%20XRP%20for%20Salesforce%20User%20Guide.pdf)

Admin Stories: [Visual Representation](https://github.com/MuKnSys/xrp-salesforce/blob/main/Documentation%20and%20Images/XRP%20for%20Salesforce%20Admin%20Story%20Map.png)

User Stories: [Visual Representation](https://github.com/MuKnSys/xrp-salesforce/blob/main/Documentation%20and%20Images/XRP%20for%20Salesforce%20User%20Story%20Map.png)


## Submitting changes to GitHub

1. Create a feature / change branch - you will need to fork the project
1. Pull changes from Salesforce `sf project retrieve start`
1. Push changes to GitHub
1. Create a pull request

## Notes - Convert sf scratch org creation command to sfdx

`sfdx force:org:create -f config/project-scratch-def.json --setalias xrpsalesforce1 --durationdays 30 --setdefaultusername --json --loglevel fatal`

## Copyright and License

Copyright 2023 Mutual Knowledge Systems, Inc.  XRP Salesforce is distributed under the GPL licence, version 3.0.  For more information, see the [LICENSE file](LICENSE).
