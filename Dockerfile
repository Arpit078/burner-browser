FROM ubuntu:18.04

ENV USER=root
ENV DEBIAN_FRONTEND=noninteractive 
ENV DEBCONF_NONINTERACTIVE_SEEN=true

# Install necessary packages
RUN apt-get update && \
    echo "tzdata tzdata/Areas select America" > ~/tx.txt && \
    echo "tzdata tzdata/Zones/America select New York" >> ~/tx.txt && \
    debconf-set-selections ~/tx.txt && \
    apt-get install -y abiword gnupg apt-transport-https wget software-properties-common ratpoison novnc websockify libxv1 libglu1-mesa xauth x11-utils xorg tightvncserver curl build-essential nginx && \
    wget https://kumisystems.dl.sourceforge.net/project/virtualgl/2.6.5/virtualgl_2.6.5_amd64.deb && \
    wget https://kumisystems.dl.sourceforge.net/project/turbovnc/2.2.7/turbovnc_2.2.7_amd64.deb && \
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt install -y ./google-chrome-stable_current_amd64.deb && \
    dpkg -i virtualgl_*.deb && \
    dpkg -i turbovnc_*.deb && \
    mkdir ~/.vnc/ && \
    mkdir ~/.dosbox && \
    echo "set border 1" > ~/.ratpoisonrc && \
    echo "exec google-chrome --no-sandbox" >> ~/.ratpoisonrc && \
    openssl req -x509 -nodes -newkey rsa:2048 -keyout ~/novnc.pem -out ~/novnc.pem -days 3650 -subj "/C=US/ST=NY/L=NY/O=NY/OU=NY/CN=NY emailAddress=email@example.com" && \
    touch /root/.Xauthority

# Expose the ports used by the application
EXPOSE 80

# Set VNC password
RUN echo "test" | vncpasswd -f > ~/.vnc/passwd && \
    chmod 0600 ~/.vnc/passwd

# Install Rust and Cargo
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH=/root/.cargo/bin:$PATH

# Copy the Rust project files
COPY . .

# Build the Rust program
RUN cargo build --release

# Write the Nginx configuration
# RUN echo 'events {} http { server { listen 8080; server_name localhost; location /api { proxy_pass http://localhost:3000; proxy_set_header Host $host; proxy_set_header X-Real-IP $remote_addr; proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; proxy_set_header X-Forwarded-Proto $scheme; } location /viewer { proxy_pass http://localhost:80; proxy_set_header Host $host; proxy_set_header X-Real-IP $remote_addr; proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; proxy_set_header X-Forwarded-Proto $scheme; } location / { try_files $uri $uri/ =404; } location /websockify { proxy_pass http://localhost:5901; proxy_http_version 1.1; proxy_set_header Upgrade $http_upgrade; proxy_set_header Connection "upgrade"; proxy_set_header Host $host; proxy_set_header X-Real-IP $remote_addr; proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; proxy_set_header X-Forwarded-Proto $scheme; } } }' > /etc/nginx/nginx.conf
CMD /opt/TurboVNC/bin/vncserver && websockify -D --web=/usr/share/novnc/ --cert=~/novnc.pem 80 localhost:5901 && tail -f /dev/null 
