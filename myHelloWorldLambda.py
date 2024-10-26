def lambda_handler(event, context):
    # Extract the 'greeting' value from the input
    greeting_message = event.get("greeting", "Hello, World!")  # default if key is missing
    
    # Retrieve the version from the context
    function_version = context.function_version
    
    # Construct the HTML content with inline CSS for styling
    html_content = f"""
    <html>
      <head>
        <style>
          body {{
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background-color: #f0f8ff;
            color: #333;
          }}
          h1 {{
            font-size: 48px;
            color: #4CAF50;
            font-family: Arial, sans-serif;
            text-align: center;
          }}
          p {{
            font-size: 24px;
            color: #777;
          }}
        </style>
      </head>
      <body>
        <div>
          <h1>{greeting_message}</h1>
          <p>Version: {function_version}</p>
        </div>
      </body>
    </html>
    """
    
    # Return the HTML response
    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "text/html"
        },
        "body": html_content
    }
