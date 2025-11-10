# prometheus-k6-fusion

**prometheus-k6-fusion** is a lightweight Go-based API server that provides CRUD operations for sample data objects and exposes Prometheus metrics.  
It includes a set of **Grafana k6 scripts** that generate real-time load to simulate traffic and visualize metrics — a perfect demo of **observability in action**.

# Target Audience
- **Developers learning Prometheus integration** in Go.
- **Teams exploring observability setups** with Prometheus and Grafana.
- **People practicing performance** testing with k6.
- **Interview/demo projects** to showcase system design, metrics, and automation skills.

It’s very small repo to have a quick start yet rich enough to demonstrate end-to-end observability concepts.

# Why It’s Useful
- Provides a **ready-to-run environment** for:
  - CRUD REST API (in Go)
  - Prometheus metrics exposure
  - k6 traffic generation
- Ideal for learning, teaching, or demonstrating:
  - Metrics instrumentation best practices
  - Monitoring pipelines
  - Performance & load testing workflows


# Introduction
While learning prometheus, it has been often challenging to have real world application metrics. The prometheus-k6-fusion applicatino solves this problem by exposing the following metrics at the endpoint `http://localhost:7080/metrics`:


| Metric | Type | Description |
|---|---|---|
| `http_requests_total` | Counter | Total number of HTTP requests processed, labeled by status code and method. |
| `http_status_code` | Counter | HTTP status code |
| `http_requests_in_progress` | Gauge | Number of HTTP requests currently being processed.|
| `http_request_duration_seconds` | Histogram | Histogram of HTTP request durations in seconds. |
| `person_store_count` | Gauge | Number of person records currently stored in memory. |
| `person_created_total` | Counter | Total number of persons created successfully.|
| `person_deleted_total` | Counter| Total number of persons deleted successfully.|
| `person_not_found_total` | Counter | Total number of operations attempted on nonexistent persons. |
| `person_payload_size_bytes` | Histogram | Size of JSON payloads in POST /person. |
| `app_cpu_usage_percent` | Gauge | CPU usage of the Go process (percent).|
| `app_memory_usage_megabytes` | Gauge | Memory usage of the Go process (MB). |

# How it works
This has two components: 
- **Prometric** : The lightweight Go API server exposing Prometheus metrics, calling this prometric (prometheus+metric)
-  **K6 Script**: The **Grafana k6 scripts** that generate real-time load to simulate traffic.

## Prometric
Prometric is a lightweight API server written in Go that provides CRUD operations for Person objects. It uses an in-memory database and exposes Prometheus metrics for observability.

### Features
- RESTful API for managing Person objects (Create, Read, Update, Delete)
- In-memory storage (no external database required)
- Built-in Prometheus metrics for monitoring
- Runs on port :7080 by default

### API Endpoints

| Method | Endpoint        | Description                 |
| ------ | --------------- | --------------------------- |
| GET    | `/person/list`      | List all persons            |
| GET    | `/persons/{id}` | Get a specific person       |
| POST   | `/person`      | Create a new person         |
| PUT    | `/person/{id}` | Update an existing person   |
| DELETE | `/person/{id}` | Delete a person             |
| GET    | `/metrics`      | Prometheus metrics endpoint |


## K6 Script
I use [Grafan k6](https://k6.io/) to generate traffic against the prometric API. This [k6-scripts](./scripts/k6-scripts.js) demonstrates a simple scenario that exercises the CRUD endpoints for Person objects.

### What the script does
- Creates some 50K Objects (ie Person) in ~10 mins (50000 iterations shared among 50 VUs, maxDuration: 10m).
- Tries to get Person by Random Id for 10 mins (20.00 iterations/s for 10m0s, maxVUs: 10).
- Tries to get Person list  for 10 mins (10.00 iterations/s for 10m0s, maxVUs: 5).
- Updates the Person for 5 mins (5.00 iterations/s for 2m0s, maxVUs: 5).
- Deletes about 1500 Persons randomly within 10 mins (1500 iterations shared among 2 VUs,maxDuration: 10m0s).

These above iterations are enough to generate some adequate prometheus metrics which can be used to play with prometheus and grafana dashboard.

# Getting Started

## Run Locally
- Clone the repo and run the app
```bash
$ git clone https://github.com/peek8/prometheus-k6-fusion.git
$ cd prometheus-k6-fusion
$ go run main.go
```

- The API server will start on http://localhost:7080. You can use tools like curl or Postman to interact with the endpoints for testing. Access Prometheus metrics at: `http://localhost:7080/metrics`.

- Install [Grafan k6](https://k6.io/) at your local machine and run the k6-scripts from the repo:

```bash
$ k6 run ./scripts/k6-scripts.js
```
And now if you hit the metric endpoint, you will see different metric values keep changing.

## Use Docker
- Run the api server first:
```bash
$ docker run \
--rm -p 7080:7080 \
ghcr.io/peek8/prometric:latest
```
With this, The API server will start on http://localhost:7080.

- Run the k6 script with grafana/k6 image:

```bash
$ docker run -i --rm \
  -e BASE_URL=http://host.docker.internal:7080 \
  grafana/k6:latest  run  - < ./scripts/k6-scripts.js
```

if you are using podman use `BASE_URL=http://host.containers.internal:7080`. 

If you are at linux, you might need to add `--add-host` extra param. For example, at linux, you use the following command for docker: 
```bash
$ docker run -i --rm \
  --add-host=host.docker.internal:host-gateway \
  -e BASE_URL=http://host.docker.internal:8080 \
  grafana/k6:latest run  - < ./scripts/k6-scripts.js 
```

