export default function Header({ cartCount, onShopClick }) {
  return (
    <header className="site-header">
      <a className="brand" href="#top" aria-label="RoastCart home"><span className="brand-mark">R</span>RoastCart</a>
      <nav aria-label="Main navigation">
        <a href="#coffee" onClick={onShopClick}>Shop coffee</a>
        <a href="#story">Our story</a>
      </nav>
      <button className="cart-button" type="button" aria-label={`Cart with ${cartCount} items`}>
        <span aria-hidden="true">Bag</span><b>{cartCount}</b>
      </button>
    </header>
  )
}
