# Authentication: Make sure to include your username and password into the
# authentication_request.json file
wget -Uri https://okapi-development.eu.auth0.com/oauth/token -Headers @{"content-type"="application/json"} -Method POST -Body $(get-content authentication_request.json -raw) -OutFile "token.json"


# Read the token content from the token.json. Note: You need jq for that to work
$token = (Get-Content '.\token.json' | ConvertFrom-Json).access_token

# Send your request to the server. You can change the request in the pass_prediction_request.json file.
wget -Uri https://api.okapiorbits.com/predict-passes/sgp4/requests -Headers @{"content-type"="application/json";"Accept"="application/json";"Authorization"='Bearer '$token} -Method POST -Body $(get-content pass_prediction_request.json -raw) -OutFile "request_response.json"

# Wait a moment to let the server process the request
Start-Sleep -s 3


# Get the request id from request_response.json and remove the quotes
$request_id = (Get-Content '.\request_response.json' | ConvertFrom-Json).request_id

# Contact the server and retrieve the pass prediction result with the extracted request id
wget -Uri https://api.okapiorbits.com/predict-passes/sgp4/results/${request_id}/summary -Headers @{"Authorization"='Bearer '$token} -OutFile "pass_prediction_result.json"

# Wait, so that you can read the server response
Start-Sleep -s 3

# Print it nicely to the terminal
Get-Content .\pass_prediction_result.json | ConvertFrom-Json  | ConvertTo-Json
