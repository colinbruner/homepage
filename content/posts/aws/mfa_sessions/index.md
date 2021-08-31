+++
title = "Generating AWS MFA Sessions with YubiKey"
date = 2021-08-29

[extra]
author = "Colin Bruner"

[taxonomies]
tags = ["aws", "cloud", "guides"]
+++

## Foreword
I generally like to write in a way that demonstrates my voice, through the telling of stories or sharing
relatable experiences and mishaps.

However, the following is more written as a technical document / guide. This method of MFA has worked
well with me when managing a handful of AWS accounts. As a true multi-account architecture begins to
surface, using SSO to authenticate sessions for API calls is just going to be a more sane option.

## Objective
Often times there's a need to generate a time based session or token with an identity provider in
order to access certain aspects of the system. I find this to be a general good practice as well
given that you'll be forced to reassert your identity at the end of every TTL for the session.

So that's great, the manual reauthenticating and generating of those sessions can suck. With the
guide below, I wanted to take a jab at automating the process against AWS STS.

## Adding MFA Device
Login to the AWS Console, you should see <USERNAME> @ <ACCOUNT> in the top right corner. 
Click on this dropdown and select My Security Credentials.

Scroll down the page until you see Multi-factor authentication (MFA) header. If you already have 
an MFA device and want to remove it in order to use YubiKey click "Manage MFA device" and select 
remove.

{{ show_image(img="manage_mfa.png") }}

Click "Assign MFA device" and chose "Virtual MFA" device.

{{ show_image(img="assign_mfa.png") }}

You’ll be prompted with the below screen… click Show secret key and keep that value safe for later.

{{ show_image(img="setup_mfa.png") }}

Do NOT exit the above popup window!

Now, jump into your local terminal shell. You’ll want to install the ykman utility to manage your YubiKey.

```bash
$ brew install ykman
```

Once the command is installed, validate your YubiKey has the correct enabled USB interfaces.

```bash
$ ykman info | grep 'Enabled USB'
Enabled USB interfaces: OTP, FIDO, CCI
```

Once this is validated, add your MFA to ykman with the following command.

```bash
$ ykman oath accounts add -t arn:aws:iam::<AWS_ACCOUNT_ID>:mfa/<USERNAME> <MFA_SECRET>
```

The AWS_ACCOUNT_ID can be found under the <USERNAME> @ <ACCOUNT> dropdown from earlier. 
The username is your AWS login username. The <MFA_SECRET> is the value from the “Show secret key” 
link in the above screenshot.

You can validate this worked by listing your ykman accounts.

```bash
$ ykman oath accounts list arn:aws:iam::<ACCOUNT_ID>:mfa/<USERNAME>
```

Now, generate two MFA codes by running the following. You will be prompted to touch your YubiKey.

$ ykman oath accounts code arn:aws:iam::<ACCOUNT_ID>:mfa/<USERNAME>

This command can be run multiple times to return the same code. The code will automatically cycle every ~30s.

Once that is complete and entered into the MFA code 1 and MFA code 2 fields from above… you should 
receiving the following notification.

{{ show_image(img="success_mfa.png") }}

## Automating 

Now that the YubiKey has been added as your MFA, we’re going to discuss how we can automate this 
on the CLI.

### Logging into the Console

When logging into https://console.aws.amazon.com/ You will now be prompted for a 6 digit code to 
login to the console, similar to how you would be with Duo or Google Authenticator. 

I feel it’s a step back from being able to just touch your YubiKey and authenticate… but with the
code below, you can at least run a command to copy it to your clipboard. 

Personally, I find that easier than fumbling through your phone and manually typing it in. 

### The Code

Copy the below script to a file somewhere within your PATH and make it executable.

As you can see, you’ll need to edit expected AWS_ACCOUNT and ACCOUNT_ID values.

```bash
aws_get_token() {
  AWS_ACCOUNT=${1:-production}
  # Determine account ID
  if [[ ${AWS_ACCOUNT} == 'production' ]]; then
    ACCOUNT_ID=12345678910
  elif [[ ${AWS_ACCOUNT} == 'staging' ]]; then
    ACCOUNT_ID=13579101010
  elif [[ ${AWS_ACCOUNT} == 'testing' ]]; then
    ACCOUNT_ID=98765432110
  else
    echo "Account ${AWS_ACCOUNT} not found. Exiting."
    exit 1
  fi

  #NOTE: Assumes your local $USER matches your AWS login name. Change this if it's not the case.
  TOKEN=$(ykman oath accounts code arn:aws:iam::${ACCOUNT_ID}:mfa/${USER} | awk '{print $2}')

  # Copy token to clipboard
  echo $TOKEN | pbcopy
  # Echo to STDOUT
  echo $TOKEN
}

aws_get_token "$@"
```

### The Command

```bash
$ aws_get_token
Touch your YubiKey...
419413
```

That’s it, the token will now be on your clipboard and in your shells STDOUT!

## Creating a Session

We’re going to create a session and write it back to ~/.aws/credentials file, and we’re going to 
do it fully with the YubiKey setup from above. 

The first order of business is adding a [script][ags] to your local $PATH. I created a $HOME/.bin and add 
this to my PATH within my login shell, so this is where I’ll be referencing. 

Download the [script][ags] and [edit it][agsedit] to properly reflect the account name -> account id mapping. 

This should look something like the following:

```python
AWS_ACCOUNTS = {
  "production": "12345678910", 
  "staging": "13579101010", 
  "testing": "98765432110"
}
```

Once that is complete, ensure the AWS Python SDK library is installed.

```bash
$ pip3 install boto3
```

Finally, in order to create a session named "production" the script will expect an AWS_PROFILE 
named base_production within your ~/.aws/credentials file. These are the AWS credentials that will 
be used to request a new session, "production" from the AWS API. 

Please see the following note [in code][agsnote], feel free to modify it to your hearts content.

### Running The Commands

With this properly setup, we should be able to use it by running the following commands

```bash
$ aws_get_token
Touch your YubiKey...
$ aws-gen-session production <copy_pasted_6_digit_mfa>
```

This will write the ~/.aws/credentials with a [production] profile with a session lasting the 
default 86400 seconds (24hours).

### One Step Further

Using the shell script from above, I’ve added one additional function to be even lazier with this whole process.

```bash
$ aws_gen_session production
Touch your YubiKey...
Successfully created a session for production
```

All you’ll need is a 2nd shell function called aws_gen_session the code for this is below…

```bash
aws_gen_session() {
  # Generate a session for an AWS account profile.
  # The AWS account must be setup properly to generate an MFA_CODE from yubikey
  # The user must have the `aws-gen-session` script in PATH
  AWS_ACCOUNT=${1:-production}
  TOKEN=$(aws_get_token ${AWS_ACCOUNT})
  aws-gen-session ${AWS_ACCOUNT} ${TOKEN}
  if [[ "$?" == 0 ]]; then
    echo "Successfully created a session for ${AWS_ACCOUNT}"
  else
    echo "Error: $? - something went wrong."
  fi
}
```

As you can see, we’re really just wrapping all of the above functions and scripts into one command flow. 
Which I feel works out pretty nicely!

[ags]: https://raw.githubusercontent.com/colinbruner/dotfiles/master/states/bin/files/scripts/aws/aws-gen-session
[agsedit]: https://github.com/colinbruner/dotfiles/blob/master/states/bin/files/scripts/aws/aws-gen-session#L49
[agsnote]: https://github.com/colinbruner/dotfiles/blob/master/states/bin/files/scripts/aws/aws-gen-session#L51-L53
