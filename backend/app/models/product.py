from datetime import datetime, timezone

from backend.app.extensions import db


class Product(db.Model):
    __tablename__ = "products"

    id = db.Column(db.Integer, primary_key=True)

    sku = db.Column(
        db.String(50),
        unique=True,
        nullable=False,
        index=True,
    )

    product_name = db.Column(
        db.String(120),
        nullable=False,
    )

    origin = db.Column(
        db.String(120),
        nullable=False,
    )

    description = db.Column(db.Text, nullable=False)

    tasting_notes = db.Column(
        db.Text,
        nullable=True,
    )

    price = db.Column(
        db.Numeric(10, 2),
        nullable=False,
    )

    roast_level = db.Column(
        db.String(50),
        nullable=False,
    )

    image_url = db.Column(
        db.String(500),
        nullable=True,
    )

    is_active = db.Column(
        db.Boolean,
        nullable=False,
        default=True,
    )

    created_at = db.Column(
        db.DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
    )

    updated_at = db.Column(
        db.DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
    )
