import { useEffect, useMemo, useState } from "react";
import Header from "./components/Header.jsx";
import ProductCard from "./components/ProductCard.jsx";

const filters = [
  "All coffee",
  "Light roast",
  "Medium roast",
  "Dark roast",
  "Espresso roast",
];

export default function App() {
  const [products, setProducts] = useState([]);
  const [activeFilter, setActiveFilter] = useState("All coffee");
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState("");
  const [query, setQuery] = useState("");
  const [cartCount, setCartCount] = useState(0);

  // FETCH FROM FLASK API /products
  useEffect(() => {
    async function loadProducts() {
      try {
        const response = await fetch("/api/v1/products");

        if (!response.ok) {
          throw new Error("Unable to load products.");
        }

        setProducts(await response.json());
      } catch (error) {
        setError(error.message);
      } finally {
        setIsLoading(false);
      }
    }

    loadProducts();
  }, []);

  const visibleProducts = useMemo(() => {
    const normalizedQuery = query.trim().toLowerCase();
    return products.filter((product) => {
      const matchesFilter =
        activeFilter === "All coffee" || product.roast === activeFilter;
      const searchText = [
        product.name,
        product.origin,
        product.tastingNotes,
        product.roast,
      ]
        .filter(Boolean)
        .join(" ")
        .toLowerCase();
      return matchesFilter && searchText.includes(normalizedQuery);
    });
  }, [products, activeFilter, query]);

  const scrollToCoffee = () =>
    document.getElementById("coffee")?.scrollIntoView({ behavior: "smooth" });

  return (
    <main id="top">
      <Header
        cartCount={cartCount}
        onShopClick={(event) => {
          event.preventDefault();
          scrollToCoffee();
        }}
      />
      <section className="hero">
        <div className="hero-copy">
          <p className="hero-kicker">Small lots. Big morning energy.</p>
          <h1>
            Coffee worth
            <br />
            <em>waking up for.</em>
          </h1>
          <p className="hero-text">
            Beautifully sourced beans, roasted with care and sent straight to
            your door.
          </p>
          <button
            className="primary-button"
            type="button"
            onClick={scrollToCoffee}
          >
            Find your roast <span>↓</span>
          </button>
        </div>
        <div className="hero-visual" aria-label="A bag of RoastCart coffee">
          <div className="sun-circle" />
          <div className="hero-bag">
            <span className="bag-arch" />
            <div className="bag-label">
              <span>ROAST</span>
              <b>Cart</b>
              <i>FRESHLY ROASTED</i>
            </div>
            <p>EST. 2026</p>
          </div>
          <div className="scribble">
            good days
            <br />
            start here
          </div>
        </div>
      </section>

      <section className="coffee-section" id="coffee">
        <div className="section-heading">
          <div>
            <p className="eyebrow">The current lineup</p>
            <h2>Find your daily ritual.</h2>
          </div>
          <div className="search">
            <label htmlFor="coffee-search" className="sr-only">
              Search coffee
            </label>
            <span>⌕</span>
            <input
              id="coffee-search"
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              placeholder="Search coffee"
            />
          </div>
        </div>
        <div className="filter-row" aria-label="Filter by roast">
          {filters.map((filter) => (
            <button
              key={filter}
              type="button"
              className={activeFilter === filter ? "active" : ""}
              onClick={() => setActiveFilter(filter)}
            >
              {filter}
            </button>
          ))}
        </div>

        <div className="product-grid">
          {isLoading && <p>Loading Coffees..</p>}
          {error && <p className="empty-state">{error}</p>}

          {!isLoading &&
            !error &&
            visibleProducts.map((product) => (
              <ProductCard
                key={product.id}
                product={product}
                onAddToCart={() => setCartCount((count) => count + 1)}
              />
            ))}
        </div>
        {!isLoading && !error && visibleProducts.length === 0 && (
          <p className="empty-state">
            No coffees found. Try a different search.
          </p>
        )}
      </section>
      <section className="story-band" id="story">
        <span>✦</span>
        <p>Roasted in small batches for the way you actually drink coffee.</p>
        <span>✦</span>
      </section>
    </main>
  );
}
