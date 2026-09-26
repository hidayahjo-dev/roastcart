from decimal import Decimal

from backend.app import create_app
from backend.app.extensions import db
from backend.app.models.product import Product

app = create_app()


products = [
    Product(
        sku="RC-ETH-001",
        name="Ethiopia Yirgacheffe",
        description="Light and floral coffee with citrus, jasmine, and bergamot notes.",
        price=Decimal("18.90"),
        roast_level="Light Roast",
        image_url=None,
    ),
    Product(
        sku="RC-COL-001",
        name="Colombia Huila",
        description="Balanced coffee with caramel sweetness, red apple, and chocolate notes.",
        price=Decimal("17.50"),
        roast_level="Medium Roast",
        image_url=None,
    ),
    Product(
        sku="RC-BRA-001",
        name="Brazil Santos",
        description="Smooth and nutty coffee with milk chocolate and hazelnut notes.",
        price=Decimal("16.90"),
        roast_level="Medium Roast",
        image_url=None,
    ),
    Product(
        sku="RC-SUM-001",
        name="Sumatra Mandheling",
        description="Full-bodied coffee with earthy, herbal, and dark chocolate notes.",
        price=Decimal("19.50"),
        roast_level="Dark Roast",
        image_url=None,
    ),
    Product(
        sku="RC-GUA-001",
        name="Guatemala Antigua",
        description="Rich and balanced coffee with cocoa, spice, and subtle citrus notes.",
        price=Decimal("18.50"),
        roast_level="Medium Roast",
        image_url=None,
    ),
    Product(
        sku="RC-ESP-001",
        name="RoastCart Espresso Blend",
        description="Bold espresso blend with dark chocolate, caramel, and roasted nut notes.",
        price=Decimal("20.00"),
        roast_level="Espresso Roast",
        image_url=None,
    ),
]


with app.app_context():
    existing_product = db.session.execute(
        db.select(Product).limit(1)
    ).scalar_one_or_none()

    if existing_product:
        print("Products already exist. Seed skipped.")

    else:
        db.session.add_all(products)
        db.session.commit()

        print(f"Successfully seeded {len(products)} products.")
