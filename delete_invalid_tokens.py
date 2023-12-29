#NOTE: cron job is set to run every 24 hours 0 * * * * /path/to/your/python /path/to/your/cleanup_script.py

import psycopg2
import os
from dotenv import load_dotenv
load_dotenv()

db_params = {
    'host': os.getenv('POSTGRES_HOST'),
    'database': os.getenv('POSTGRES_DB'),
    'user': os.getenv('POSTGRES_USER'),
    'password': os.getenv('POSTGRES_PASSWORD'),
}

try:
    connection = psycopg2.connect(**db_params)
    cursor = connection.cursor()

    cleanup_query = """
        DELETE FROM user_sessions WHERE created_at <= CURRENT_TIMESTAMP - INTERVAL '48 hours';
        DELETE FROM token_blacklist WHERE logout_date <= CURRENT_TIMESTAMP - INTERVAL '48 hours';
    """

    cursor.execute(cleanup_query)
    connection.commit()

    print("Cleanup operation completed successfully.")

except Exception as e:
    print(f"Error during cleanup: {e}")

finally:
    if cursor:
        cursor.close()
    if connection:
        connection.close()