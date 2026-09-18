from flask import Flask, request

app = Flask(__name__)

@app.route("/search")
def search():
    query = request.args.get("q")
    return query

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)