from flask import Flask, render_template, request, jsonify
from db import get_connection

app = Flask(__name__)

@app.route("/")
def index():
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("SELECT country_id, country_name FROM dim_countries ORDER BY country_name")
    countries = cur.fetchall()
    cur.execute("SELECT indicator_id, indicator_name FROM dim_indicators ORDER BY indicator_id")
    indicators = cur.fetchall()
    cur.close()
    conn.close()
    return render_template("index.html", countries=countries, indicators=indicators)

@app.route("/data")
def data():
    country = request.args.get("country", "VNM")
    indicator_id = request.args.get("indicator", 1)
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT t.year_id, f.value, t.is_crisis_year
        FROM fact_economic_data f
        JOIN dim_time t ON f.year_id = t.year_id
        WHERE f.country_id = %s AND f.indicator_id = %s
        ORDER BY t.year_id
    """, (country, indicator_id))
    rows = cur.fetchall()

    cur.execute("""
        SELECT definition FROM dim_indicators WHERE indicator_id = %s
    """, (indicator_id,))
    definition = cur.fetchone()

    cur.close()
    conn.close()
    return jsonify({
        "chartData": [{"year": r[0], "value": float(r[1]), "crisis": r[2]} for r in rows],
        "definition": definition[0] if definition else ""
    })

@app.route("/country/<country_id>")
def country_detail(country_id):
    conn = get_connection()
    cur = conn.cursor()
    cur.execute("""
        SELECT c.country_name, r.region_name
        FROM dim_countries c
        JOIN dim_regions r ON c.region_id = r.region_id
        WHERE c.country_id = %s
    """, (country_id,))
    country = cur.fetchone()
    cur.execute("""
        SELECT i.indicator_name, f.year_id, f.value, u.unit_name
        FROM fact_economic_data f
        JOIN dim_indicators i ON f.indicator_id = i.indicator_id
        JOIN dim_units u ON i.unit_id = u.unit_id
        WHERE f.country_id = %s
        ORDER BY i.indicator_id, f.year_id
    """, (country_id,))
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return render_template("country.html", country=country, rows=rows, country_id=country_id)

if __name__ == "__main__":
    app.run(debug=True)