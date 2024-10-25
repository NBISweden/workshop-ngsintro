from flask import Flask, send_from_directory
import os
import subprocess
import yaml
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import time

app = Flask(__name__)
quarto_yml_path = '_quarto.yml'
watched_folder = '.'

# Function to read the output directory from _quarto.yml
def read_output_dir_from_quarto_yml(quarto_yml_path):
    with open(quarto_yml_path, 'r') as file:
        quarto_config = yaml.safe_load(file)
    return quarto_config.get('project', {}).get('output-dir', 'default-output-folder')


class QuartoHandler(FileSystemEventHandler):
    def __init__(self):
        self.last_modified_time = {}

    def should_process(self, file_path, cooldown=2):
        # Check the time of the last modification for the given file
        last_time = self.last_modified_time.get(file_path, 0)
        # Get the current time
        current_time = time.time()
        # If the last modification was more recent than the cooldown, skip processing
        if current_time - last_time < cooldown:
            return False
        # Update the last modification time and proceed
        self.last_modified_time[file_path] = current_time
        return True

    def on_modified(self, event):
        if not event.is_directory and event.src_path.endswith('.qmd'):
            if self.should_process(event.src_path):
                print(f"Detected changes in {event.src_path}. Rendering...")
                # Run the Quarto render command for the specific file
                subprocess.run(['quarto', 'render', event.src_path])


# Set up file watcher
event_handler = QuartoHandler()
observer = Observer()
observer.schedule(event_handler, watched_folder, recursive=True)
observer.start()


@app.route('/')
def index():
    # Serve the index.html file
    return send_from_directory(output_folder, 'index.html')

@app.route('/<path:filename>')
def serve_file(filename):
    # Serve the rendered file
    return send_from_directory(output_folder, filename)


if __name__ == '__main__':
    output_folder = "../" + read_output_dir_from_quarto_yml(quarto_yml_path)  # Update the output folder on the startup, adding ../ to account for this script being in scripts/
    app.run(host='0.0.0.0', port=5000, debug=True)

