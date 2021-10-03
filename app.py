from flask import Flask, request
from pushover import Client, Message
from twilio.twiml.messaging_response import MessagingResponse
import logging
import os


logger = logging.getLogger('waitress')
logger.setLevel(logging.INFO)
app = Flask(__name__)


# https://www.twilio.com/docs/messaging/guides/webhook-request
@app.route('/push', methods=['GET', 'POST'])
def push():
    """Forward incoming text message to Pushover."""

    client = Client(
        os.getenv('PUSHOVER_USER_KEY'),
        os.getenv('PUSHOVER_API_TOKEN')
    )

    msg = Message(request.form['Body'], title=request.form['From'])
    r = client.send(msg)
    if r.status_code != 200:
        raise Exception(f"Pushover failed: {r.status_code}")

    # empty response
    resp = MessagingResponse()

    return str(resp), 200, {'Content-Type': 'text/xml; charset=utf-8'}


@app.route('/')
def index():
    return 'no can do'


if __name__ == "__main__":
    app.run(debug=True)
