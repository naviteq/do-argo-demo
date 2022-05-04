#!env python

from flask import Flask
import os

app = Flask(__name__)

@app.route("/")
def hello_world():
    return "<p>Hello from the application {}!</p>".format(os.environ["VERSION"])
