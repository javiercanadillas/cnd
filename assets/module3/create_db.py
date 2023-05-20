import os
import logging

from google.cloud.sql.connector import Connector
import sqlalchemy

# Set up logging (use logging.DEBUG for more information)
logging.basicConfig(level=logging.INFO, format='%(levelname)s - %(message)s')

# Initialize Connector object
logging.info("Initializing connector")
connector = Connector()

# Return a connection to the database
def getconn():
  instance_connection_name = os.environ["INSTANCE_CONNECTION_NAME"]
  db_user = os.environ["DB_USER"]
  db_pass = os.environ["DB_PASS"]
  db_name = os.environ["DB_NAME"]
  logging.info( "Connection data:\n"
                f"  Database   : {db_name}\n"
                f"  User/pass  : {db_user}/{db_pass}\n"
                f"  Conn string: {instance_connection_name}")
  try:
    conn = connector.connect(
      instance_connection_name,
      "pg8000",
      user=db_user,
      password=db_pass,
      db=db_name,
    )  
    return conn
  except Exception:
     logging.exception("Error creating connection pool")

# Create connection pool with creator argument to our connection object function
logging.info("Creating connection pool")
pool = sqlalchemy.create_engine(
  "postgresql+pg8000://",
  creator=getconn,
)

with pool.connect() as db_conn:
  logging.info("Creating 'ratings' table")
  db_conn.execute(
    sqlalchemy.text(
      "CREATE TABLE IF NOT EXISTS ratings "
      "( id SERIAL NOT NULL, name VARCHAR(255) NOT NULL, "
      "origin VARCHAR(255) NOT NULL, rating FLOAT NOT NULL, "
      "PRIMARY KEY (id));"
    )
  )

  logging.info("Committing transaction")
  # Commit the transaction
  db_conn.commit()

  # insert data into our ratings table
  logging.info("Inserting data into 'ratings' table")
  insert_stmt = sqlalchemy.text(
      "INSERT INTO ratings (name, origin, rating) VALUES (:name, :origin, :rating)",
  )

  # insert entries into table
  try:
    db_conn.execute(insert_stmt, parameters={
        "name": "TOTOPOS",
        "origin": "Mexico",
        "rating": 8.5})
    db_conn.execute(insert_stmt, parameters={
        "name": "CHURROS",
        "origin": "Spain",
        "rating": 9.1})
    db_conn.execute(insert_stmt, parameters={
        "name": "CROQUE MADAME",
        "origin": "France",
        "rating": 8.3})
  except Exception:
    logging.exception("Error inserting data into table")
  
  # Read from the votes table
  logging.info("Reading from 'ratings' table")
  results = db_conn.execute(sqlalchemy.text("SELECT * FROM ratings")).fetchall()
  
  # Show the results of the SELECT statement
  for row in results:
      print(row)

# Clean up
connector.close()
