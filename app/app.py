import socket
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello():
    hostname = socket.gethostname()
    return f"Hello! I am running a new version on pod: {hostname}\n"

@app.route('/health')
def health():
    return "OK", 200

if __name__ == '__main__':
    # 0.0.0.0 is crucial. If you use 127.0.0.1, the container 
    # will isolate the app and K8s won't be able to reach it.
    app.run(host='0.0.0.0', port=5000)
    