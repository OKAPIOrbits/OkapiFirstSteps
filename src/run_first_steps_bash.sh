#!/bin/bash

# Authentication: Make sure to include your username and password into the
# authentication_request.json file
wget --server-response --quiet --body-file=authentication_request.json --output-document=token.json --header="content-type: application/json" --method=POST https://okapi-development.eu.auth0.com/oauth/token

# Read the token content from the token.json. Note: You need jq for that to work
ACCESS_TOKEN_VALUE=`cat token.json | jq --raw-output .access_token`

# Send your request to the server. You can change the request in the pass_prediction_request.json file.
wget --content-on-error --output-document=request_response.json --body-file=pass_prediction_request.json --header="Content-Type: application/json" --header="Accept: application/json" --header="access_token: ${ACCESS_TOKEN_VALUE}"  --method=POST http://okapi.ddns.net:34569/pass/prediction/requests

# wait a moment to let the server process the request
sleep 3

# get the result
request_id=`cat request_response.json | jq '.requestId'`
wget --content-on-error --output-document=pass_prediction_result.json --header="access_token: ${ACCESS_TOKEN_VALUE}" http://okapi.ddns.net:34569/pass/predictions/${request_id}

# wait, so that you can read the server response
sleep 3

# print it nicely to the terminal
cat pass_prediction_result.json | jq .