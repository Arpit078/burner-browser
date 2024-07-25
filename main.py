from pyvirtualdisplay import Display
import os

# Start virtual display
display = Display(visible=0, size=(1024, 768))
display.start()

# Start VNC server
os.system("tightvncserver :1")

# Your VNC server is now running on port 5901
print("VNC server is running on port 5901")
