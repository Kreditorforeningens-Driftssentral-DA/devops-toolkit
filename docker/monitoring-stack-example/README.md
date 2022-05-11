# Example Monitoring stack

## Description

  * [Grafana](http://localhost:3000) for visualizing metrics & logs. (grafana/grafana)
  * [Grafana Loki](http://localhost:3100) for storing & receiving logs.
  * [Grafana Mimir](http://localhost:8080) for storing prometheus metrics.
  * [Prometheus](http://localhost:9090) for scraping metrics from services.
  * [MinIO](http://localhost:9001) for loki backend storage (s3). (minio/SecretKey)
  * [Fluent-bit](http://localhost:2020) for generating logs (dummy) to loki
  * Telegraf for ActiveMQ input -> prometheus output

## Running

```bash
# Start/build services
$ docker compose -f docker-compose.yml up -d

# Start/build services & extra examples
$ docker compose up -d

# Stop all
$ docker compose down 

# Cleanup minio data
$ docker compose down --volumes --remove-orphans
```

## References

  * https://raw.githubusercontent.com/minio/minio/master/docs/orchestration/docker-compose/docker-compose.yaml
  * https://grafana.com/docs/loki/latest/fundamentals/architecture/
  * https://blog.min.io/how-to-grafana-loki-minio/