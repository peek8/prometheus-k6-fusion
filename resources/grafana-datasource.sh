curl -X POST http://admin:admin@localhost:3000/api/datasources \
  -H "Content-Type: application/json" \
  -d '{
    "name": "prometric-k6",
    "type": "prometheus",
    "access": "proxy",
    "url": "http://prometheus:9090",
    "jsonData": {
      "timeInterval": "5s"
    }
  }'
