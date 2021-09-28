Set up a ubuntu dev machine in AWS.

# Requirements
* aws-vault `brew install aws-vault` [[usage]](https://github.com/99designs/aws-vault/blob/439cc770ca046c6f53b38145c0ccb39620563a8f/USAGE.md#managing-credentials)
* terraform `brew install terraform`
* python3 `brew install python3`

# Setup

```bash
git clone git@github.com:TheDeveloper/dev-machine.git
cd dev-machine
```

## Setup
```bash
./bin/setup
```

# Usage

## Set variables in .env, then:
```bash
./bin/create
```

## Teardown
```bash
./bin/destroy
```
# Details

## Install ansible
```bash
python3 -m venv env && \
source env/bin/activate && \
pip3 install ansible && \
ansible-galaxy install diodonfrost.terraform && \
ansible-galaxy install darkwizard242.awsvault
```

## Create .env
```bash
cp .env.example .env
```

## Init terraform
```bash
terraform init
```

## Generate setup key for ec2 instance
```
ssh-keygen -t ed25519 -N '' -f ./key
```

## Do this for every new shell
```bash
source env/bin/activate
```

```bash
source ./.env
```

## Run terraform plan to test
```bash
aws-vault exec $DM_AWS_VAULT_ROLE -- \
  terraform plan \
  -var "instance_type=$DEVMACHINE_INSTANCE_TYPE" \
  -var "ami=$DEVMACHINE_AMI" \
  -var "vpc_id=$DEVMACHINE_VPC_ID" \
  -var "name=$DEVMACHINE_NAME" \
  -var "subnet=$DEVMACHINE_SUBNET" \
  -var "kms_key_arn=$DEVMACHINE_KMS_KEY_ARN"a
```

## Create resources
```bash
aws-vault exec $DM_AWS_VAULT_ROLE -- \
  terraform apply \
  -var "instance_type=$DEVMACHINE_INSTANCE_TYPE" \
  -var "ami=$DEVMACHINE_AMI" \
  -var "vpc_id=$DEVMACHINE_VPC_ID" \
  -var "name=$DEVMACHINE_NAME" \
  -var "subnet=$DEVMACHINE_SUBNET" \
  -var "kms_key_arn=$DEVMACHINE_KMS_KEY_ARN"
```

## Tear down resources
```bash
aws-vault exec $DM_AWS_VAULT_ROLE -- \
  terraform destroy \
  -auto-approve \
  -var "instance_type=$DEVMACHINE_INSTANCE_TYPE" \
  -var "ami=$DEVMACHINE_AMI" \
  -var "vpc_id=$DEVMACHINE_VPC_ID" \
  -var "name=$DEVMACHINE_NAME" \
  -var "subnet=$DEVMACHINE_SUBNET" \
  -var "kms_key_arn=$DEVMACHINE_KMS_KEY_ARN"
```

## Verify values
```bash
terraform state show aws_instance.instance
```
```bash
terraform output -raw ip
```

## Set up ssh access
```bash
# trailing comma is required to specify ip list
DM_IP=$(terraform output -raw ip)
DEVMACHINE_HOST="$DM_IP,"
```
```bash
ansible-playbook \
  --private-key "$(pwd)/key" \
  -i $DEVMACHINE_HOST \
  playbooks/ssh.yaml
```
```bash
ssh "ubuntu@$DEVMACHINE_HOST"
```
## Add ssh host
https://stormssh.readthedocs.io/en/latest/index.html
```bash
pip3 install stormssh
```
```bash
storm add $DEVMACHINE_NAME ubuntu@$DM_IP
```
```bash
# or update
storm edit $DEVMACHINE_NAME ubuntu@$DM_IP
```
```bash
storm delete $DEVMACHINE_NAME
```
```bash
ssh "ubuntu@$DEVMACHINE_NAME"
```
## Upgrade packages
```bash
ansible-playbook \
  -i "$DEVMACHINE_NAME," \
  playbooks/upgrade.yaml
```

## Setup workspace folders
```bash
ansible-playbook \
  -i "$DEVMACHINE_NAME," \
  playbooks/workspace.yaml
```

## Install nvm
```bash
ansible-playbook \
  -i "$DEVMACHINE_NAME," \
  playbooks/nvm.yaml
```

```bash
ansible-playbook \
  -i "$DEVMACHINE_NAME," \
  playbooks/packages.yaml
```

```bash
ansible-galaxy install diodonfrost.terraform
ansible-playbook \
  -i "$DEVMACHINE_NAME," \
  playbooks/terraform.yaml
```

```bash
ansible-galaxy install darkwizard242.awsvault
ansible-playbook \
  -i "$DEVMACHINE_NAME," \
  playbooks/aws-vault.yaml
```

```
ssh-add -K ~/.ssh/id_ed25519
```
