from googleapiclient import discovery
from oauth2client.client import GoogleCredentials
import base64
import logging
from flask import escape
import functions_framework
import os
import urllib.request
import json

credentials = GoogleCredentials.get_application_default()
service = discovery.build('sqladmin', 'v1beta4', credentials=credentials, cache_discovery=False)

logging.basicConfig(level=logging.DEBUG)

@functions_framework.http
def manage_db(request):
    """HTTP Cloud Function.
    Args:
        request (flask.Request): The request object.
        <https://flask.palletsprojects.com/en/1.1.x/api/#incoming-request-data>
    Returns:
        The response text, or any set of values that can be turned into a
        Response object using `make_response`
        <https://flask.palletsprojects.com/en/1.1.x/api/#flask.make_response>.
    """
    request = request.get_data()
    try: 
        request_json = json.loads(request.decode())
    except ValueError as e:
        logging.info(f"Error decoding JSON: {e}")
        return "JSON Error", 400

    logging.info(f"request_json: {request_json}")

    if request_json and 'action' in request_json:
        action = request_json['action']
        db_instance_name = request_json['db_instance_name']
    else:
        logging.info("Nothing to do")
        return 'Nothing to do'
    
    project = get_project_id()
    
    if action.lower() == 'stop':
        stop(project, db_instance_name)
        return 'Stop the instance'
    elif action.lower() == 'start':
        start(project, db_instance_name)
        return 'Start the instance'
    else:
        return 'Nothing to do'


def get_project_id():    
    '''retrieve the project id where the function is running'''
    url = "http://metadata.google.internal/computeMetadata/v1/project/project-id"
    req = urllib.request.Request(url)
    req.add_header("Metadata-Flavor", "Google")
    project_id = urllib.request.urlopen(req).read().decode()
    return project_id

def start(project, instance_name):
  logging.info("starting " + instance_name)
  patch(project, instance_name, "ALWAYS")

def stop(project, instance_name):
  logging.info("stopping " + instance_name)
  patch(project, instance_name, "NEVER")

def patch(project, instance, activation_policy):
  dbinstancebody = {
    "settings": {
      "settingsVersion": response["settings"]["settingsVersion"],
      "activationPolicy": activation_policy
    }
  }

  request = service.instances().patch(
    project=project,
    instance=instance,
    body=dbinstancebody)
  response = request.execute()
  logging.debug(response)