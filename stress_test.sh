#!/bin/bash
echo "Starting stress test on http://localhost:8080/up..."
echo "Press CTRL+C to stop."

SUCCESS=0
FAIL=0

start_time=$(date +%s)

while true; do
    # curl with timeout, checking only status code
    STATUS=$(curl -o /dev/null -s -w "%{http_code}\n" --max-time 2 http://localhost:8080/up)
    
    if [ "$STATUS" == "200" ]; then
        SUCCESS=$((SUCCESS+1))
        echo -ne "\r[$(date +%s)] Success: $SUCCESS | Fail: $FAIL | Last: $STATUS"
    else
        FAIL=$((FAIL+1))
        echo -e "\n[$(date +%s)] FAILED! Status: $STATUS"
    fi
    
    # Slight delay to not kill the machine entirely if curl is instand
    # sleep 0.01 
done
