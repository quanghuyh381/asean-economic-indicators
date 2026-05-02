import psycopg2

def get_connection():
    return psycopg2.connect(
        host="localhost",
        dbname="ASEAN_Macroeconomics_Indicators",
        user="postgres",
        password="huy2712",
        port=2712
    )