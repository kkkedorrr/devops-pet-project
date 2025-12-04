import socket
from flask import Flask

# 1. Change variable name to 'flask_app'
flask_app = Flask(__name__)

# 2. Update the decorator
@flask_app.route('/')
def hello():
    hostname = socket.gethostname()
    return f"Hello from Argo! Version 2 is live on pod: {hostname}\n"

@flask_app.route('/health')
def health():
    return "OK", 200

if __name__ == '__main__':
    # 3. Update the run command
    flask_app.run(host='0.0.0.0', port=5000)
