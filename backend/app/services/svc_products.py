from backend.app.extensions import db
from backend.app.models.product import Product


def svc_get_all_products():
    stmt = db.select(Product).where(Product.is_active.is_(True)).order_by(Product.id)

    products = db.session.execute(stmt).scalars().all()
    return [
        {
            "id": product.id,
            "sku": product.sku,
            "name": product.name,
            "description": product.description,
            "price": str(product.price),
            "roast_level": product.roast_level,
            "image_url": product.image_url,
        }
        for product in products
    ]
