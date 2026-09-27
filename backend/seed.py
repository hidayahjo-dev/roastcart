from decimal import Decimal

from backend.app import create_app
from backend.app.extensions import db
from backend.app.models.product import Product

app = create_app()


products = [
    Product(
        sku="RC-ETH-001",
        product_name="Ethiopia Yirgacheffe",
        origin="Yirgacheffe, Ethiopia",
        description=(
            "A bright and aromatic single-origin coffee with a delicate body "
            "and lively acidity."
        ),
        tasting_notes="Bergamot, peach, white magnolia, honey",
        price=Decimal("18.90"),
        roast_level="Light Roast",
        image_url=None,
    ),
    Product(
        sku="RC-COL-001",
        product_name="Colombia Huila",
        origin="Huila, Colombia",
        description=(
            "A balanced and approachable coffee with smooth sweetness "
            "and a clean finish."
        ),
        tasting_notes="Caramel, red apple, milk chocolate, brown sugar",
        price=Decimal("17.50"),
        roast_level="Medium Roast",
        image_url=None,
    ),
    Product(
        sku="RC-BRA-001",
        product_name="Brazil Cerrado",
        origin="Cerrado Mineiro, Brazil",
        description=(
            "A smooth, full-bodied coffee with low acidity and a rich, "
            "comforting sweetness."
        ),
        tasting_notes="Hazelnut, cocoa, caramel, roasted almond",
        price=Decimal("16.90"),
        roast_level="Medium Roast",
        image_url=None,
    ),
    Product(
        sku="RC-GUA-001",
        product_name="Guatemala Antigua",
        origin="Antigua, Guatemala",
        description=(
            "A rich and structured coffee with a rounded body and "
            "a gentle citrus brightness."
        ),
        tasting_notes="Dark chocolate, orange zest, cinnamon, brown sugar",
        price=Decimal("18.50"),
        roast_level="Medium Roast",
        image_url=None,
    ),
    Product(
        sku="RC-ESP-001",
        product_name="RoastCart Espresso Blend",
        origin="Brazil & Colombia",
        description=(
            "A bold house espresso blend designed for a rich body, "
            "balanced sweetness, and a smooth finish."
        ),
        tasting_notes="Dark chocolate, caramel, roasted nuts, molasses",
        price=Decimal("20.00"),
        roast_level="Espresso Roast",
        image_url=None,
    ),
]


with app.app_context():
    db.session.add_all(products)
    db.session.commit()

    print(f"Successfully seeded {len(products)} products.")
