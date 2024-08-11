# Infrastructure Security Health Assesment Tool

The script contained in this folder aim to provide an easy and automated ability to asses the security
health of two aspects of the existing infrastructure: 

- Ensuring that instances are always updated to the latests AMI version, hence ensuring we always have the latest security updates.

- Validating all security groups to ensure they are being properly implemented and not just allowing all traffic.

## Requirements

- Ensure that the python interpreter is present in your system and that the `boto3` module is installed using `pip install boto3`.

- Ensure your aws configuration is properly configured and you are authenticated towards your aws environment and that either a `default` profile exists or that you provide to the script an existing profile name in `~.aws/config`.

## How to Run the Script

The script can be run in three different ways:
- Run only instance checks -> `python security-assesor.py instances my-profile`
- Run only security group checks -> `python security-assesor.py sgs my-profile`
- Run all -> `python security-assesor.py all my-profile`

## Notes of implementation

### Assumptions and decisions

- The implementation assumes and relies on the aws cli configuration being properly configured. The requirement of choosing the `region` where the checks are performed is satisfied via allowing to provide the `profile` to use to the script.

- The script is provided into a single script file to Keep It Simple although modularization would be interesting in a real scenario to encourage reusability and structure.

- The script assumes that all the AMIs follow the convention `${ami_base_name}-v${ami-version}`, other formats should be added to the scripting to support other image name formats as to correlate images as different versions of the same image we need to rely on the naming convention.

- The usage of the boto client assumes the execution spans in such a short span of times that the boto client can be cached and safely assume the session is not closed during the time of execution. Failing on fulfilling this assumption would make the script fail as there is no error handling for these cases.

- The script assumes that the volumes mounted on the image ( besides the OS disk - which should not contain non-temp or os data) are configured to only be detached and not destroyed when the associated instance is destroyed.

### AMI update process - real world approach

Although, on a real world scenario, to satisfy the outlayed requirements we would target the IaC code and perform the necessary modifications there and also leverage zero-downtime rollout strategies rather than targetting directly the cloud resources, on the provided solution we use the AWS API and leverage a more manual method so to showcase scripting abilities as its understood as the intention behind this exercise.

One would also look at using automated solutions like `renovatebot` together with proper cicd gates to automate this process and remove unnecessary operational and maintenance burdens.

## Test Cases

In order to validate the functionality of the script the following test cases can be implemented which would provide a sufficient level of coverage to ensure functionality is not broken when iterating the script.

NOTE: For creating instances use the following command to obtain the list of available AMI versions for the supported image. Use the first in the list when needing to create up to date instances and any other to create outdated ones.

```bash
aws ec2 describe-images \
    --owners amazon \
    --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
    --query "reverse(sort_by(Images[*].{ImageID:ImageId,Name:Name,CreationDate:CreationDate}, &CreationDate))" \
    --output table [--profile <your-profile>]
```

### TC1 - No Security Groups and/or instances present for provided profile
1. Setup a profile to a region/account with no instances nor security groups
2. Run the script
3. Validate the script works without errors and it performs no actions

### TC2 - Instances exist but are up to date
1. Create multiple instances which are up to date and match the supported AMI format
2. Run the script
3. The script should show the complete list of instances and iterate over the up to date instances and report them as up to date and not attempt to perform any actions.

### TC3 - Security Groups match security requirements
1. Create several security groups which do not include ingress rules with source set to `0.0.0.0/0` nor `::/0`. Set some outbound rules too and set at least two of them to `0.0.0.0/0` and `::/0` to validate outbound rules are not analyzed for a match.
2. Run the script.
3. Validate the script processes all the created security groups but does not suggest any changes.

### TC4 - Validate Environments are listed.
1. Ensure multiple instances exist in the following states (`running`, `stopped`, `terminated`). For each of them set a different environment key. One instance must have a duplicated environment value.
2. Run the script
3. Ensure the script outputs all the different environment values and shows no duplicated values.

### TC5 - Validate Outdated AMIs are detected and updated when matching supported format
1. Reuse the instances from the previous test cases.
2. Create an additional instance with multiple EBS volumes and using an outdated AMI.
3. Run the script.
4. Verify:
    - All the running instances are listed
    - The outdated instance is flagged. The rest are omitted as they are up to date.
    - For the outdated instance
        - A backup AMI is created corresponding to th instance that we are updating.
        - A new instance is created as an exact clone of the old instance which has
            - new root volume
            - matching security group and subnet to the original instance
            - all the ebs/non-root volumes from the original instance are now mapped to the new instance
            - same tags (`Environment` and `Name`) 
        - The old instance is terminated

### TC6 - Validate Outdated AMIs are not updated and the script works when ami format is not supported
1. Reuse the instances from the previous test cases.
2. Create an additional instance with multiple EBS volumes and using an outdated AMI but from a different image type which does not match the format of the amazon linux image used so far.
3. Run the script.
4. Verify:
    - All the running instances are listed
    - The outdated instance is flagged. The rest are omitted as they are up to date.
    - For the outdated instance
        - A backup AMI is created corresponding to th instance that we are updating.
        - A new instance is created as an exact clone of the old instance which has
            - new root volume
            - matching security group and subnet to the original instance
            - all the ebs/non-root volumes from the original instance are now mapped to the new instance
            - same tags (`Environment` and `Name`) 
        - The old instance is terminated

### TC7 - Security groups violate security requirements
1. Reuse the security groups from TC3
2. Create two additional security groups both of which have one rule with source set to `0.0.0.0` and another to `::/0`. Each rule should have different values for the other rule properties. Add additional rules which source set to valid ip ranges.
3. Run the script.
4. Validate:
    - All the security groups are processed correct and not.
    - Only the newly created security groups are flagged as non compliant
    - A correction proposal is shown listing 4 rules (all the created non compliant rules)
    - Answer `no` when asked to remove the violating rules.
    - Verify the script finishes successfully and no rules are removed.
5. Run the script.
6. Validate:
    - All the security groups are processed correct and not.
    - Only the newly created security groups are flagged as non compliant
    - A correction proposal is shown listing 4 rules (all the created non compliant rules)
    - Answer `yes` when asked to remove the violating rules.
    - Verify the script finishes successfully and the violating rules have been removed.
