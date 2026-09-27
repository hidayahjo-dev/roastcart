from flask import Flask
from flask_cors import CORS
from backend.config import Config
from .extensions import db

from .routes.health import health_bp
from .routes.products import products_bp


def create_app():
    app = Flask(__name__)
    # CORS(app)

    app.config.from_object(Config)
    db.init_app(app)

    app.register_blueprint(health_bp)
    app.register_blueprint(products_bp)

    return app
