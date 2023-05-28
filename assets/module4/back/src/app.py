import datetime
import os
from typing import Dict

from flask import Flask, request, Response, jsonify
import sqlalchemy

from connect_connector import connect_with_connector
from base_logger import logger

app = Flask(__name__)

def init_connection_pool() -> sqlalchemy.engine.base.Engine:
  if os.environ.get("INSTANCE_CONNECTION_NAME"):
    return connect_with_connector()

  raise Exception("No connection found")

# Initialize the connection pool when the application starts
with app.app_context():
  global db
  db = init_connection_pool()


@app.route("/get_votes", methods=["GET"])
def render_index() -> Response:
  logger.info("Getting votes from database")
  try:
    context = get_index_context(db)
    message = {
      'status': 200,
      'message': 'OK',
      'data': context
    }
    logger.info(f"Returning message: {message}")
    return jsonify(message)
  except Exception as e:
    logger.exception(e)
    message = {
      'status': 500,
      'message': 'Internal Server Error'
    }
    return jsonify(message)


@app.route("/cast_vote", methods=["POST"])
def cast_vote() -> Response:
  content = request.get_json()
  logger.info(f"Receiving vote request {content}")
  # Ignoring the number of votes as this is not implemented yet
  team: str = content["team"]
  if not team:
    logger.warning("Received request with no team specified.")
    message = {
      'status': 400,
      'message': "Bad Request. 'team' property not found."
    }
    return jsonify(message)
  message = {
    'status': 200,
    'message': 'OK',
  }
  logger.info(f"Saving vote for team {team}")
  save_vote(db, team)
  resp = jsonify(message)
  logger.info(f"Got response from database function: {resp}")
  return resp


# get_index_context gets data required for rendering HTML application
def get_index_context(db: sqlalchemy.engine.base.Engine) -> Dict:
  votes = []

  with db.connect() as conn:
    # Execute the query and fetch all results
    recent_votes = conn.execute(sqlalchemy.text(
      "SELECT candidate, time_cast FROM votes ORDER BY time_cast DESC LIMIT 5"
    )).fetchall()
    # Convert the results into a list of dicts representing votes
    for row in recent_votes:
        votes.append({"candidate": row[0], "time_cast": row[1]})

    stmt = sqlalchemy.text(
      "SELECT COUNT(vote_id) FROM votes WHERE candidate=:candidate"
    )
    # Count number of votes for tabs
    tab_count = conn.execute(stmt, parameters={"candidate": "TABS"}).scalar()
    # Count number of votes for spaces
    space_count = conn.execute(stmt, parameters={"candidate": "SPACES"}).scalar()

  return {
    "space_count": space_count,
    "recent_votes": votes,
    "tab_count": tab_count,
  }


# save_vote saves a vote to the database that was retrieved from form data
def save_vote(db: sqlalchemy.engine.base.Engine, team: str) -> Dict:
  
  time_cast = datetime.datetime.now(tz=datetime.timezone.utc)
  status_msg = {
    'cast': True,
    'message': f"Successfully cast vote for team f{team}!"
  }

 # Verify that the team is one of the allowed options
  if team != "TABS" and team != "SPACES":
      logger.warning(f"Received invalid 'team' property: '{team}'")
      status_msg = {
        'cast': False,
        'message': f"Invalid team specified: '{team}'."
      }

  try:
    stmt = sqlalchemy.text(
      "INSERT INTO votes (time_cast, candidate) VALUES (:time_cast, :candidate)"
    )
    with db.connect() as conn:
      conn.execute(stmt, parameters={"time_cast": time_cast, "candidate": team})
      conn.commit()
      logger.info(f"Vote successfully inserted into the database for team {team}")
  except Exception as e:
    logger.exception(e)
    status_msg = {
      'cast': False,          
      'message': "Unable to successfully cast vote! Please check the "
                 "application logs for more details."
    }

  return status_msg


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=8080, debug=True)