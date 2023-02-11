 curl -H 'Content-Type: application/json' \
      -d '{ "title":"Test Title","body":"This is the body of the notification"}' \
      -X POST \
      http://localhost:3000/notify