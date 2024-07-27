from flask import Flask, redirect, url_for
import os
app = Flask(__name__)

ROUTE_TO_PORT_MAPPING = {
    "server1": {
        "busy" : False,
        "port" : "5001"
    },
    "server2": {
        "busy" : False,
        "port" : "5002"
    },
    "server3": {
        "busy":False,
        "port":"5003"
    }
}

@app.route("/")
def index():
    for server in ROUTE_TO_PORT_MAPPING:
        if not ROUTE_TO_PORT_MAPPING[server]["busy"]:
            ROUTE_TO_PORT_MAPPING[server]["busy"] = True
            port = ROUTE_TO_PORT_MAPPING[server]["port"]
            os.system("sudo docker build -t burner-browser . --build-arg PASSWORD=arpit")
            os.system(f"sudo docker run -p {port}:80 burner-browser" )
            return redirect(f'http://localhost:{port}/vnc.html')
        
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
