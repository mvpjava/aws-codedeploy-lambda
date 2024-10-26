Used for my demo mainly in AWS Console where you have already created a CodeDeploy Applcation, Deployment Group and deploymnet (and IAM Roles, CW Alarm to monitor during deployment).
Along the way, you will need to provide the appspec.yml file. Either directly pasted in AWS Console or copy it to an S3 Location.

Make sure to deploy these Lambdas first and create 2 versions for the main lambda (myHelloWorldLambda), create a lambda alias for the main lambda since this is referenced in appspec.yml

This is not really meant for public consumption as there is no automation setup but I still share it for those who know what they are doing
and need some examples to facilitate creating the lambdas and appspec file for you own setup. 

I will probably add the automation as time allows
