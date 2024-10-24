# XRP for Salesforce

![](https://github.com/MuKnSys/xrp-salesforce/blob/main/Documentation%20and%20Images/XRP-For-Salesforce.png)

This is a basic demonstration Salesforce DX Project. Using the [SF CLI](https://developer.salesforce.com/tools/sfdxcli) tools, you can deploy to a Developer Edition Scratch Org.

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## Salesforce Developer Edition

You can get a free Salesforce Developer Edition account from Salesforce. Sign up at:

https://developer.salesforce.com/signup

## How To Test the App - Unlocked Package v1.0.2
1. Install the app using one of these links:
    - [Production](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tTO0000001d8zYAA)
    - [Sandbox](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tTO0000001d8zYAA)

2. Log in using existing Salesforce login credentials to access the app as an [unlocked package](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_unlocked_pkg_whats_a_package.htm).

## How To Test the App - Using Repository

1. Checkout the Main Branch.
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

Once you've set up your Salesforce Scratch Org, you can follow the steps outlined in our [user guide](https://github.com/MuKnSys/xrp-salesforce/blob/main/Documentation%20and%20Images/Web3%20Enabler%20XRP%20for%20Salesforce%20%20-%20User%20Guide%20v1.0.2.pdf), starting from the "Set up XRPL Webhooks Account" section, to proceed with the setup process.  We've also made available in [Japanese](https://docs.google.com/document/d/1kp7_nAsx4zq3D1UlrXCQlG5G1ZIAuhGrVr7ibMQsRYo), to make XRP for Salesforce as globally accessible as possible :earth_asia:. 

We launched Web3 Enabler on the Salesforce App Exchange in July, 2023.  See our [AppExchange listing](https://appexchange.salesforce.com/appxListingDetail?listingId=ee4c011b-7a5b-4a50-91fb-f28049390858) for further details.

## User/Admin Story Documentation
User Guide: [XRP for Salesforce User Guide](https://github.com/MuKnSys/xrp-salesforce/blob/main/Documentation%20and%20Images/Web3%20Enabler%20XRP%20for%20Salesforce%20%20-%20User%20Guide%20v1.0.2.pdf)

Admin Stories: [Visual Representation](https://github.com/MuKnSys/xrp-salesforce/blob/main/Documentation%20and%20Images/XRP%20for%20Salesforce%20Admin%20Story%20Map.png)

User Stories: [Visual Representation](https://github.com/MuKnSys/xrp-salesforce/blob/main/Documentation%20and%20Images/XRP%20for%20Salesforce%20User%20Story%20Map.png)


## The Code Integration

We offer up REST Endpoints in Salesforce to receive the data.

We register an endpoint on our Salesforce Installation to receive the data from the Webhook.
We then subscribe any company addresses to the Webhook.
The data is then parsed inside of Salesforce for business logic.


## Plans for XRP for Salesforce V2

We will provide unlocked and managed packages for the main XRP for Salesforce application plus the Cloud specific add ons (6 packages in total), as part of our commercial offering, as a Salesforce ISV partner.  See our [technical architecture diagram](https://github.com/MuKnSys/xrp-salesforce/blob/main/Documentation%20and%20Images/xrp-for-salesforce-v2-technical-architecture.png), as a reference.

Unlocked Packages (the 2GP Packaging system improvement on the 1GP Unmanaged Packages) provides open installation. Managed Packages must go through the extensive security review for Salesforce.

To be comparable with the 2GP Packaging system, we offer a base package, usable on ANY Salesforce Org (also called a Force.com or Platform installation), plus add-ons for the common and logical Salesforce “Clouds” - their name for products.

Most Salesforce installations include:
* [Sales or Service Cloud](https://www.salesforce.com/sales)
* Ecommerce solutions, which utilize [Commerce Cloud](https://www.salesforce.com/commerce)
* [Accounting Seed](https://www.accountingseed.com): a third party product that offers a full General Ledger/ERP (Enterprise Resource Planning) environment in Salesforce.

Part of the v2 Project is to submit the base package and the addons into the Security Review process. While the actual cost for submission is inexpensive (approximately $3,000 including listing fees), the compliance portion of this is time consuming. We will have to document and clear the Webhooks project with Salesforce Security Review. For Web3 Enabler, it was a 2 month project for our internal application.

See this [video](https://www.youtube.com/watch?v=f1-dhhkNkII) to better understand our plans for v2 and our [Blockchain Payments v2.2 demo](https://youtu.be/njLyeOkhUqU) to get a sense of the full set of features offered by our commercial Web3 Enabler for Salesforce product.


## Submitting changes to GitHub

1. Create a feature / change branch - you will need to fork the project
1. Pull changes from Salesforce `sf project retrieve start`
1. Push changes to GitHub
1. Create a pull request

## Notes - Convert sf scratch org creation command to sfdx

`sfdx force:org:create -f config/project-scratch-def.json --setalias xrpsalesforce1 --durationdays 30 --setdefaultusername --json --loglevel fatal`

## Copyright and License

Copyright 2024 Web3 Enabler, Inc.  XRP Salesforce is distributed under the GPL licence, version 3.0.  For more information, see the [LICENSE file](LICENSE).
