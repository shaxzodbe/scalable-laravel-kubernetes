# Scalable Laravel Architecture on Kubernetes 🚀

This repository demonstrates a **High-Performance, Enterprise-Grade** architecture for hosting Laravel applications on Kubernetes. It moves beyond the traditional Nginx + PHP-FPM setup to leverage modern technologies for superior speed and scalability.

## 🏆 Key Achievements

We transformed a standard Laravel application into a high-performance system:

*   **9.5x Performance Boost**: Optimized request handling from ~160 RPS to **~1,514 RPS**.
*   **Drastically Lower Latency**: Reduced average response time from 314ms to **33ms**.
*   **Zero-Downtime Deployment**: Verified Rolling Updates with readiness probes.
*   **Self-Healing**: Automatic pod replacement in case of failure (Chaos Monkey tested).

## 🏗 Architecture Highlights

### 1. Runtime: FrankenPHP + Laravel Octane
We utilize **FrankenPHP** in "Worker Mode" (powered by **Laravel Octane**).
*   **Why?** Instead of booting the framework for every request (traditional PHP-FPM), the application stays loaded in memory.
*   **Result:** Blazing fast response times and higher throughput.

### 2. Kubernetes Best Practices
*   **Horizontal Pod Autoscaling (HPA)**: Automatically scales Web pods based on CPU/Memory pressure.
*   **Stateless Design**: Usage of S3 for files and Redis for sessions/cache allows pods to be ephemeral.
*   **Security**: Minimal `Alpine` based images, Network Policies restricting traffic, and Secrets management.

### 3. Separation of Concerns
*   **Web Deployment**: Handles HTTP traffic (Scales on CPU).
*   **Worker Deployment**: Handles Background Queues (Scales on Queue Depth).
*   **Scheduler**: Dedicated cron runner.

## 🛠 Quick Start

We have provided a fully automated script to deploy this stack to a local [Kind](https://kind.sigs.k8s.io/) cluster for testing.

```bash
# 1. Setup Cluster & Deploy
./setup_demo.sh

# 2. Expose the App
kubectl port-forward service/laravel-web 8080:80
```

### Verification Scripts
*   **`./stress_test.sh`**: Generates load to demonstrate performance.
*   **`./chaos_test.sh`**: Deletes random pods to verify self-healing capabilities.

## 📊 Benchmark Results (A/B Test)

| Metric | Standard Mode (FPM-like) | Worker Mode (FrankenPHP) |
| :--- | :--- | :--- |
| **Requests/Sec** | 160 RPS | **1,514 RPS** |
| **Latency** | 314ms | **33ms** |

---
*Built with Laravel 12, FrankenPHP, and Kubernetes.*
