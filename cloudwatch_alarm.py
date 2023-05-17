import os
import boto3


def create_cloudwatch_alarm(instance_id):
    region = os.environ.get('ap-south-1')  # Get the region from the environment variable

    client = boto3.client('cloudwatch', region_name='ap-south-1')

    response = client.put_metric_alarm(
        AlarmName='High_CPU_Usage',
        AlarmDescription='Alert when CPU usage exceeds 80% for 5 consecutive minutes',
        ActionsEnabled=False,
        AlarmActions=[],
        MetricName='CPUUtilization',
        Namespace='AWS/EC2',
        Statistic='Average',
        Dimensions=[
            {
                'Name': 'InstanceId',
                'Value': instance_id
            },
        ],
        Period=60,  # 1 minute
        EvaluationPeriods=5,  # Number of periods to evaluate for the alarm
        Threshold=80.0,
        ComparisonOperator='GreaterThanThreshold',
        TreatMissingData='notBreaching',
    )

    print('CloudWatch alarm created successfully.')

# Replace 'instance_id' with the actual EC2 instance ID
create_cloudwatch_alarm('Terraform')
