# 🌏 ASEAN Macroeconomic Indicators Dashboard

An interactive web dashboard visualising macroeconomic data across 10 ASEAN countries from 2000 to 2023, built on a PostgreSQL database with a Python Flask web application.

## 🔗 Links
- **Live Website:** [ASEAN Economic Indicators](https://web-production-360b6.up.railway.app)
- **GitHub:** [github.com/quanghuyh381/asean-economic-indicators](https://github.com/quanghuyh381/asean-economic-indicators)

---

## ✨ Features

- 📈 **Interactive line charts** — visualise any economic indicator over time for any ASEAN country
- 🗺️ **Income status map** — choropleth map showing World Bank income classifications with a year slider
- 📊 **Correlation analysis** — powered by a PostgreSQL function with 3 modes:
  - Single country — correlate two indicators within one country
  - Compare countries — correlate indicators across two countries
  - All countries — correlate across all 10 ASEAN countries simultaneously
- 📥 **Data export** — download any dataset as CSV or Excel with formatted headers and crisis year highlighting
- 🔍 **Country detail pages** — full data tables for each country across all indicators
- 📖 **Indicator descriptions** — auto-displayed definition for each selected indicator

---

## 🛠️ Tech Stack

### Back-end
| Tool | Purpose |
|---|---|
| Python | Main programming language |
| Flask | Web framework |
| PostgreSQL | Relational database |
| psycopg2 | Python to PostgreSQL connector |
| openpyxl | Excel file generation |

### Front-end
| Tool | Purpose |
|---|---|
| HTML / CSS | Page structure and styling |
| JavaScript | Interactivity and data fetching |
| Chart.js | Line charts and scatter plots |
| Leaflet.js | Interactive choropleth map |

### Deployment
| Tool | Purpose |
|---|---|
| Git / GitHub | Version control |
| Railway | Cloud hosting platform |
| Gunicorn | Production web server |

---

## 🗄️ Database Design

The database follows a **star schema** data warehouse design.

### Fact Tables
| Table | Description |
|---|---|
| `fact_economic_data` | Core economic indicators by country and year |
| `fact_exchange_rates` | Official exchange rate data |
| `fact_country_income` | World Bank income group classification by year |

### Dimension Tables
| Table | Description |
|---|---|
| `dim_countries` | 10 ASEAN countries with ISO codes |
| `dim_indicators` | Economic indicators with definitions and units |
| `dim_time` | Years with crisis year flags (2008, 2009, 2020, 2021) |
| `dim_regions` | Geographic regions |
| `dim_income_groups` | World Bank income classifications |
| `dim_units` | Measurement units |
| `dim_sources` | Data sources |

### Advanced Features
- **Stored procedures** — correlation analysis and cross-sectional regression
- **PostgreSQL functions** — `correlate()` with single, compare and all modes
- **Audit logging** — trigger tracking all INSERT, UPDATE, DELETE operations
- **Data quality procedure** — detects and reports missing data
- **Table partitioning** — on `fact_economic_data` for performance

---

## 🌍 ASEAN Countries Covered

| Country | Code |
|---|---|
| Brunei Darussalam | BRN |
| Cambodia | KHM |
| Indonesia | IDN |
| Laos | LAO |
| Malaysia | MYS |
| Myanmar | MMR |
| Philippines | PHL |
| Singapore | SGP |
| Thailand | THA |
| Vietnam | VNM |

---
