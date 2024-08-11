import boto3
import sys
from re import match
from functools import cache, reduce

# Define cached functions for obtaining the boto sessions to not create a session for every function call
# and at the same time avoid passing parameters
@cache
def get_boto3_session(profile):
    return boto3.session.Session(profile_name=profile)

@cache
def get_boto3_client(profile, service):
    return get_boto3_session(profile).client(service)

@cache
def get_boto3_resource(profile, service):
    return get_boto3_session(profile).resource(service)


# Gets the latest ami for a given ami_prefix. 
# It is assumed that images with the same prefix are different versions of the same image.
def get_latest_ami(ami_prefix, ami_suffix, profile):
    ec2_client = get_boto3_client(profile, 'ec2')

    matching_amis = ec2_client.describe_images(
        Filters=[
            {'Name': 'name', 'Values': [f'{ami_prefix}*{ami_suffix}']},
            {'Name': 'state', 'Values': ['available']}
        ]
    )['Images']

    latest_ami = sorted(matching_amis, key=lambda ami: ami['CreationDate'], reverse=True)[0]
    
    return latest_ami['ImageId'], latest_ami['Name']


# Gets a list of Instance Objects for all images in State: Running
def get_running_instances(profile):
    ec2_client = get_boto3_client(profile, 'ec2')
    
    reservations = ec2_client.describe_instances(
        Filters=[
            {'Name': 'instance-state-name', 'Values': ['running']}
        ]
    )['Reservations']

    return reduce(lambda acc, res: acc + res.get('Instances'), reservations, []) if len(reservations) > 0 else []


# Creates an ami out of the provided instance_id as a restore point in case the upgrade has to be rolled back
def create_backup_ami(instance_id, profile):
    ec2_client = get_boto3_client(profile, 'ec2')
    
    return ec2_client.create_image(
        InstanceId=instance_id,
        Name=f"backup-{instance_id}",
        NoReboot=True
    )['ImageId']

# Launches a new instance with the provided ami_id reusing the configuration of a previous instance
def launch_new_instance_from_existing(latest_ami, instance, profile):
    ec2_resource = get_boto3_resource(profile, 'ec2')
    
    # Get the old instance's settings
    old_instance = ec2_resource.Instance(instance['InstanceId'])
    print(old_instance)
    
    non_root_volumes = old_instance.block_device_mappings.copy()
    del non_root_volumes[0]
    # Remove unnsupported properties on create
    root_volume = old_instance.block_device_mappings[0]
    del root_volume['Ebs']['Status']
    del root_volume['Ebs']['VolumeId']
    del root_volume['Ebs']['AttachTime']

    # Launch a new instance using the Latest AMI - only mapping some params for simplicity.
    new_instance = ec2_resource.create_instances(
        ImageId=latest_ami,
        InstanceType=old_instance.instance_type,
        SecurityGroupIds=[sg['GroupId'] for sg in old_instance.security_groups],
        SubnetId=old_instance.subnet_id,
        BlockDeviceMappings=[root_volume],
        MinCount=1,
        MaxCount=1,
        TagSpecifications=[
            {
                'ResourceType': 'instance',
                'Tags': old_instance.tags
            },
        ]
    )[0]
    
    print("Creating new instance with updated AMI. Waiting for new instance to be running...")
    new_instance.wait_until_running()
    old_instance.terminate()
    print("Terminating old instance to free up the volumes...")
    old_instance.wait_until_terminated()

    ec2_client = get_boto3_client(profile, 'ec2')
    for device_mapping in non_root_volumes:
        ec2_client.attach_volume(
            Device=device_mapping['DeviceName'],
            VolumeId=device_mapping['Ebs']['VolumeId'],
            InstanceId=new_instance.id,
            DryRun=False
        )


# Computes a list of values for the `Environment` tag present on all EC2 instances for the provided profile.
def get_distinct_environment_tags(profile):
    ec2_client = get_boto3_client(profile, 'ec2')
    
    instances = ec2_client.describe_instances()
    
    environment_tags = set()
    for reservation in instances['Reservations']:
        for instance in reservation['Instances']:
            for tag in instance.get('Tags', []):
                if tag['Key'] == 'Environment' and tag['Value'] not in environment_tags:
                    environment_tags.add(tag['Value'])
    
    return environment_tags


def ec2SecurityChecks(profile):
    running_instances = get_running_instances(profile)
    
    print("Running EC2 instances:")
    for instance in running_instances:
        print(f"- {instance['InstanceId']} - {instance['State']['Name']} - {instance['ImageId']} - {instance['Tags'][0]['Value'] if instance['Tags'] else ''}")
    print("")

    print("Verifying Instance AMIs are up to date:")
    for instance in running_instances:
        current_ami_id = instance['ImageId']

        ec2_client = get_boto3_client(profile, 'ec2')
        current_ami = ec2_client.describe_images(ImageIds=[current_ami_id])['Images'][0]
        current_ami_name = current_ami['Name']
        
        # Extract the prefix and suffix from the current AMI name (ie. 'my-ami-' and '-x86' from 'my-ami-1.2.3-x86')
        match_result = match(r'(.*-)([0-9\.]+)(-.*)', current_ami_name)
        if not match_result:
            print(f"Instance {instance['InstanceId']} AMI ({current_ami_name}) does not follow any of the supported formats. Skipping")
            break
        
        ami_prefix = match_result.group(1)
        latest_ami_id, latest_ami_name = get_latest_ami(match_result.group(1), match_result.group(3), profile)
        
        # Check if the instance is using the latest AMI
        if current_ami_id != latest_ami_id:
            print(f"Instance {instance['InstanceId']} is not using the latest AMI ({latest_ami_name}).")
            
            # Backup the instance
            backup_ami = create_backup_ami(instance['InstanceId'], profile)
            print(f"Created backup AMI: {backup_ami}")
            
            # Launch a new instance with the latest AMI
            new_instance_id = launch_new_instance_from_existing(latest_ami_id, instance, profile)
            print(f"Launched new instance {new_instance_id} with latest AMI ({latest_ami_name}).")
        else:
            print(f"Instance {instance['InstanceId']} is using the latest AMI ({current_ami_name}). Nothing to do here.")

    # Get all distinct `environment` tags
    print("")
    environment_tags = get_distinct_environment_tags(profile)
    print(f"Distinct environment tags: {environment_tags}")

def list_security_groups_with_open_ingress(profile):
    ec2_client = get_boto3_client(profile, "ec2")
    
    # Describe all security groups
    response = ec2_client.describe_security_groups()
    security_groups = response['SecurityGroups']
    
    # Initialize a list to keep track of security groups with open ingress
    open_security_groups = []
    
    for sg in security_groups:
        
        open_rules = []
        
        for rule in sg.get('IpPermissions'):
            for ip_range in rule.get('IpRanges', []):
                if ip_range.get('CidrIp') == '0.0.0.0/0':
                    open_rules.append(rule)
            for ipv6_range in rule.get('Ipv6Ranges', []):
                if ipv6_range.get('CidrIpv6') == '::/0':
                    open_rules.append(rule)
        
        if open_rules:
            open_security_groups.append({
                'GroupId': sg.get('GroupId'),
                'GroupName': sg.get('GroupName'),
                'OpenRules': open_rules
            })
    
    return open_security_groups

def remove_open_ingress_rules(security_group, profile):
    ec2_client = get_boto3_client(profile, 'ec2')
    
    ec2_client.revoke_security_group_ingress(
        GroupId=security_group.get('GroupId'), 
        IpPermissions=security_group.get('OpenRules')        
    )

def sgSecurityChecks(profile):
    # List security groups with open ingress rules
    open_security_groups = list_security_groups_with_open_ingress(profile)
    
    if not open_security_groups:
        print("No security groups with open ingress from 0.0.0.0/0 or ::/0 were found.")
        return
    
    for sg in open_security_groups:
        print(f"Security Group ID: {sg['GroupId']}, Name: {sg['GroupName']}")
        print("Open Ingress Rules:")
        for rule in sg['OpenRules']:
            print(rule)
        print("-" * 40)
    
    # Ask user for confirmation before removing rules
    confirm = input("Do you want to remove the above open ingress rules? (yes/no): ").strip().lower()
    if confirm != 'yes':
        print("Aborted by user.")
        return
    
    # Remove the open ingress rules
    for sg in open_security_groups:
        remove_open_ingress_rules(sg, profile)
        print(f"Removed open ingress rules from Security Group ID: {sg['GroupId']}, Name: {sg['GroupName']}")


def main(command, profile):
    if profile == "":
        profile = "default"

    match command:
        case "instances":
            ec2SecurityChecks(profile)
        case "sgs":
            sgSecurityChecks(profile)
        case "all":
            ec2SecurityChecks(profile)
            sgSecurityChecks(profile)

    
if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python security-assesor.py <command> [<profile>]")
        sys.exit(1)
    
    main(sys.argv[1], sys.argv[2])
