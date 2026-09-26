from flask import Blueprint, jsonify
from backend.app.data.products import products

products_bp = Blueprint("products", __name__, url_prefix="/api/v1")


@products_bp.route("/products", methods=["GET"])
def get_products():
    return jsonify(products), 200


@products_bp.route("/products/<int:product_id>", methods=["GET"])
def get_product(product_id):
    product = next(
        (product for product in products if product["id"] == product_id), None
    )

    if product is None:
        return jsonify({"error": "Product not found"}), 404

    return jsonify(product), 200
