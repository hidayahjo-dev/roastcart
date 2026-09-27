function BeanArtwork({ color }) {
  return (
    <div className={`bean-art ${color}`} aria-hidden="true">
      <span className="bean bean-one" />
      <span className="bean bean-two" />
      <span className="bean bean-three" />
      <small>ROASTCART</small>
    </div>
  );
}

export default function ProductCard({ product, color, onAddToCart }) {
  return (
    <article className="product-card">
      <div className="product-art-wrap">
        <BeanArtwork color={color} />
        {/* <span className="product-badge">{product.badge}</span> */}
      </div>
      <div className="product-details">
        <p className="eyebrow">
          {product.origin} <span>·</span>
        </p>
        <p className="eyebrow">{product.roast_level}</p>
        <h3>{product.product_name}</h3>
        <p className="notes">{product.tasting_notes}</p>
        <div className="product-footer">
          <strong>
            ${product.price}
            <small> / 250g</small>
          </strong>
          <button type="button" onClick={() => onAddToCart(product)}>
            Add to bag <span aria-hidden="true">→</span>
          </button>
        </div>
      </div>
    </article>
  );
}
