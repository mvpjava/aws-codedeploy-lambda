import boto3
import json
import time

def lambda_handler(event, context):
    # Extract necessary IDs from the event data
    deployment_id = event['DeploymentId']
    lifecycle_event_hook_execution_id = event['LifecycleEventHookExecutionId']
    
    # Initialize AWS clients
    codedeploy_client = boto3.client("codedeploy")
    cloudwatch_client = boto3.client("cloudwatch")
    
    function_name = "myHelloWorldLambda:hello-world-alias"  # specify the alias to test the new version
    
    try:
        # Check error rate in the past 5 minutes
        error_metric = cloudwatch_client.get_metric_statistics(
            Namespace="AWS/Lambda",
            MetricName="Errors",
            Dimensions=[{"Name": "FunctionName", "Value": function_name}],
            StartTime=time.time() - 300,
            EndTime=time.time(),
            Period=60,
            Statistics=["Sum"]
        )
        
        # Check latency in the past 5 minutes
        latency_metric = cloudwatch_client.get_metric_statistics(
            Namespace="AWS/Lambda",
            MetricName="Duration",
            Dimensions=[{"Name": "FunctionName", "Value": function_name}],
            StartTime=time.time() - 300,
            EndTime=time.time(),
            Period=60,
            Statistics=["Average"]
        )
        
        # Determine health based on thresholds
        error_sum = error_metric['Datapoints'][0]['Sum'] if error_metric['Datapoints'] else 0
        avg_latency = latency_metric['Datapoints'][0]['Average'] if latency_metric['Datapoints'] else 0
        
        # Set thresholds for health check
        error_threshold = 1      # Adjust as needed
        latency_threshold = 3000  # In milliseconds, adjust as needed
        
        # Check if metrics are within healthy limits
        if error_sum <= error_threshold and avg_latency <= latency_threshold:
            print("Post-traffic health check passed.")
            
            # Notify CodeDeploy of success
            codedeploy_client.put_lifecycle_event_hook_execution_status(
                deploymentId=deployment_id,
                lifecycleEventHookExecutionId=lifecycle_event_hook_execution_id,
                status="Succeeded"
            )
        else:
            print("Post-traffic health check failed.")
            print(f"Errors: {error_sum}, Latency: {avg_latency} ms")
            
            # Notify CodeDeploy of failure
            codedeploy_client.put_lifecycle_event_hook_execution_status(
                deploymentId=deployment_id,
                lifecycleEventHookExecutionId=lifecycle_event_hook_execution_id,
                status="Failed"
            )
            raise Exception("Post-traffic health check failed due to high error rate or latency.")
    
    except Exception as e:
        print(f"Error during post-traffic health check: {e}")
        
        # Notify CodeDeploy of failure in case of exception
        codedeploy_client.put_lifecycle_event_hook_execution_status(
            deploymentId=deployment_id,
            lifecycleEventHookExecutionId=lifecycle_event_hook_execution_id,
            status="Failed"
        )
        raise
