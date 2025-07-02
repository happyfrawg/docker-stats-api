Docker CPU API Backend
======================

A Flask-based REST API to fetch real-time stats (CPU and Memory usage) for running Docker containers. This API extracts stats using the docker stats command and provides the data in JSON format.

Features
--------

Fetches CPU usage of each running container (percentage).
Fetches Memory usage for containers (converted to MB).
Designed for lightweight monitoring of Docker containers.
Custom memory unit conversion support (GiB, MiB, KiB, Bytes).

Requirements
------------

Ensure you have the following installed on your system:

Python 3.6+
pip (Python package manager)
Docker (Application hosting the containers)
Flask (pip install flask)

Installation
------------

Follow these steps to set up the API:

Clone the repository or copy the application files:

`git clone https://github.com/your-username/docker-cpu-api-backend.git`
`cd docker-cpu-api-backend`
Install required Python dependencies:

`pip install flask`
Ensure that Docker is installed and the docker command is available in your terminal.

Usage
-----

To start the Flask server, run the following command:

`python3 app.py`
By default, the server will run on `http://0.0.0.0:5005`.

REST API Endpoint
-----------------

The app provides one endpoint:

`GET /stats`
This endpoint returns real-time CPU and memory usage for each Docker container running on the host machine.

Example Request:
```bash
curl http://127.0.0.1:5005/stats?api_key=123abc
```
Example Response:
```json
[
    {
        "name": "my-app-container",
        "cpuUsage": 12.45,
        "memoryUsage": 102.85
    },
    {
        "name": "db-container",
        "cpuUsage": 25.36,
        "memoryUsage": 205.20
    }
]
```

NOTE: Be sure to replace the default api_key with your actual API key when making requests to this endpoint.
Note: This script requires Docker to be installed on your system and running containers for it to work.

Explanation of the Code
----------------------

Key Functions
-------------
`convert_memory_to_mb(memory_string)`: Converts Docker memory usage strings (e.g., `1.091GiB`) to numerical values in MB.

`get_docker_stats()`: Executes the docker stats command, parses the output, and returns stats for each running container.

API Routes
----------
`GET /stats`: Returns the processed stats in JSON format. The response includes:
`name`: Name of the container.
`cpuUsage`: Percentage of CPU usage.
`memoryUsage`: Memory usage in MB.

Error Handling
--------------

The API gracefully handles errors, such as:

Docker not installed or accessible: Returns a `500 Internal Server Error` with an error message like `"Error: XYZ"`.

Invalid output from docker stats: Logs the error and skips the problematic line.

Testing
-------

Manual Testing
Start your Docker containers.

Run the Flask server.

Fetch stats via curl or a browser:

```bash
curl http://127.0.0.1:5005/stats?api_key=123abc
```
Verify that the API returns JSON data with stats for all your running containers.

Debugging
----------

If you see errors, confirm the following:

Docker is running and accessible via the terminal.
The docker stats command works without the API.

```bash
docker stats --no-stream --format="{{.Name}},{{.CPUPerc}},{{.MemUsage}}"
```
Deployment Notes
----------------

Running the API in Production

To run the Flask API in production, consider security as the primary concern.

The implementation is up to you...


License
-------

This project is licensed under the MIT License.