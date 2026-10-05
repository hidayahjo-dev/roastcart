from flask import Blueprint, jsonify

health_bp = Blueprint("health", __name__, url_prefix="/api/v1")


@health_bp.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "All good", "service": "roastcart-backend"}), 200
