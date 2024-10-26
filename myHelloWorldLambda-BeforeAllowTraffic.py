import boto3
import json

def lambda_handler(event, context):
    # Get the CodeDeploy lifecycle event details from the event data
    deployment_id = event['DeploymentId']
    lifecycle_event_hook_execution_id = event['LifecycleEventHookExecutionId']
    
    lambda_client = boto3.client("lambda")
    codedeploy_client = boto3.client("codedeploy")
    
    function_name = "myHelloWorldLambda:hello-world-alias"  # specify the alias to test the new version
    
    try:
        # Invoke the Lambda function to test the new version
        response = lambda_client.invoke(
            FunctionName=function_name,
            InvocationType="RequestResponse",
            Payload=json.dumps({"greeting": "Hello World BeforeAllowTraffic"})
        )
        
        # Parse the response
        payload = json.loads(response["Payload"].read())
        
        # Check for a successful response
        if response["StatusCode"] == 200 and "Hello World BeforeAllowTraffic" in payload.get("body", ""):
            print("Pre-traffic check passed.")
            
            # Notify CodeDeploy that the lifecycle event succeeded
            codedeploy_client.put_lifecycle_event_hook_execution_status(
                deploymentId=deployment_id,
                lifecycleEventHookExecutionId=lifecycle_event_hook_execution_id,
                status="Succeeded"
            )
        else:
            print("Pre-traffic check failed.")
            
            # Notify CodeDeploy that the lifecycle event failed
            codedeploy_client.put_lifecycle_event_hook_execution_status(
                deploymentId=deployment_id,
                lifecycleEventHookExecutionId=lifecycle_event_hook_execution_id,
                status="Failed"
            )
            raise Exception("Pre-traffic check failed.")
    
    except Exception as e:
        print(f"Error during pre-traffic check: {e}")
        
        # If there's an exception, notify CodeDeploy of failure
        codedeploy_client.put_lifecycle_event_hook_execution_status(
            deploymentId=deployment_id,
            lifecycleEventHookExecutionId=lifecycle_event_hook_execution_id,
            status="Failed"
        )
        raise
