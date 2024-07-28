FROM burner-browser-base

# Set environment variables for VNC password and screen size
ARG PASSWORD
ARG SCREEN_WIDTH
ARG SCREEN_HEIGHT

ENV SCREEN_WIDTH=${SCREEN_WIDTH}
ENV SCREEN_HEIGHT=${SCREEN_HEIGHT}
# Set VNC password
RUN mkdir -p ~/.vnc && \
    echo ${PASSWORD} | vncpasswd -f > ~/.vnc/passwd && \
    chmod 0600 ~/.vnc/passwd

# Configure VNC server and websockify
CMD /opt/TurboVNC/bin/vncserver :1 -geometry ${SCREEN_WIDTH}x${SCREEN_HEIGHT} -depth 24 && \
    websockify --web=/usr/share/novnc/ --cert=~/novnc.pem 80 localhost:5901 && \
    tail -f /dev/null
