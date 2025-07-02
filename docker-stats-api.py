from flask import Flask, jsonify, request
import subprocess

app = Flask(__name__)

# Define the valid API key
VALID_API_KEY = "123abc"  # Replace with your actual API key

def convert_memory_to_mb(memory_string):
    """
    Convert Docker-stats memory usage string (e.g., '1.091GiB') into float MB.
    """
    memory_string = memory_string.strip()  # Remove any leading/trailing spaces
    if 'GiB' in memory_string:
        # Convert GiB to MB (1 GiB = 1024 MB)
        return float(memory_string.replace('GiB', '').strip()) * 1024
    elif 'MiB' in memory_string:
        # Convert MiB to MB
        return float(memory_string.replace('MiB', '').strip())
    elif 'KiB' in memory_string:
        # Convert KiB to MB (1 KiB = 0.001 MB)
        return float(memory_string.replace('KiB', '').strip()) / 1024
    elif 'B' in memory_string:
        # Convert Bytes to MB (1 Byte = 0.000001 MB)
        return float(memory_string.replace('B', '').strip()) / (1024 * 1024)
    else:
        raise ValueError(f"Unknown memory format: {memory_string}")

def get_docker_stats():
    """
    Fetch Docker stats and convert memory usage into numeric MB.
    """
    result = subprocess.run(
        ['docker', 'stats', '--no-stream', '--format="{{.Name}},{{.CPUPerc}},{{.MemUsage}}"'],
        stdout=subprocess.PIPE,
        text=True
    )
    output = result.stdout.splitlines()
    stats = []  # List to hold processed container stats
    for line in output:
        try:
            items = line.strip('"').split(',')
            container_name = items[0]
            cpu_usage = float(items[1].strip('%'))  # Parse CPU usage (remove '%' character)
            # Parse memory usage and units (e.g., '1.091GiB / 3.492GiB')
            memory_usage_parts = items[2].split('/')
            memory_usage = convert_memory_to_mb(memory_usage_parts[0])  # Take used memory
            stats.append({
                'name': container_name,
                'cpuUsage': cpu_usage,
                'memoryUsage': memory_usage
            })
        except Exception as e:
            print(f"Error processing line: {line}. Error: {e}")
    return stats

@app.route('/stats', methods=['GET'])
def stats():
    """
    REST API endpoint to return Docker container stats.
    """
    # Check for the API key in query parameters
    api_key = request.args.get('api_key')
    if api_key != VALID_API_KEY:
        return jsonify({'error': 'Unauthorized. Invalid API key.'}), 403  # HTTP 403 Forbidden

    try:
        stats = get_docker_stats()
        return jsonify(stats), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500  # HTTP 500 Internal Server Error

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5005)  # Run the Flask server on port 5005
