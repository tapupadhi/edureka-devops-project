// Products page specific JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Get DOM elements
    const productsContainer = document.getElementById('products-container');
    const categoryFilter = document.getElementById('category-filter');
    const priceFilter = document.getElementById('price-filter');
    const priceDisplay = document.getElementById('price-display');
    const searchInput = document.getElementById('search-input');
    const searchButton = document.getElementById('search-button');
    
    // Initialize filters
    let activeFilters = {
        category: '',
        maxPrice: 3000,
        searchQuery: ''
    };
    
    // Initialize cart
    initCart();
    
    // Load products
    loadProducts();
    
    // Set up event listeners
    categoryFilter.addEventListener('change', function() {
        activeFilters.category = this.value;
        loadProducts();
    });
    
    priceFilter.addEventListener('input', function() {
        activeFilters.maxPrice = parseInt(this.value);
        priceDisplay.textContent = `$${activeFilters.maxPrice}`;
    });
    
    priceFilter.addEventListener('change', function() {
        loadProducts();
    });
    
    searchButton.addEventListener('click', function() {
        activeFilters.searchQuery = searchInput.value.trim();
        if (activeFilters.searchQuery) {
            searchProducts(activeFilters.searchQuery);
        } else {
            loadProducts();
        }
    });
    
    searchInput.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
            activeFilters.searchQuery = this.value.trim();
            if (activeFilters.searchQuery) {
                searchProducts(activeFilters.searchQuery);
            } else {
                loadProducts();
            }
        }
    });
    
    // Function to load products based on filters
    async function loadProducts() {
        // Show loading
        productsContainer.innerHTML = '<div class="loading">Loading products...</div>';
        
        // Build query string based on active filters
        let url = '/products';
        const params = new URLSearchParams();
        
        if (activeFilters.category) {
            params.append('category', activeFilters.category);
        }
        
        if (activeFilters.maxPrice < 3000) {
            params.append('max_price', activeFilters.maxPrice);
        }
        
        if (params.toString()) {
            url += `?${params.toString()}`;
        }
        
        try {
            const response = await fetch(url);
            const products = await response.json();
            
            displayProducts(products);
        } catch (error) {
            console.error('Error loading products:', error);
            productsContainer.innerHTML = '<p class="error">Failed to load products. Please try again later.</p>';
        }
    }
    
    // Function to search products
    async function searchProducts(query) {
        // Show loading
        productsContainer.innerHTML = '<div class="loading">Searching products...</div>';
        
        try {
            const response = await fetch(`/products/search/?q=${encodeURIComponent(query)}`);
            const products = await response.json();
            
            displayProducts(products);
        } catch (error) {
            console.error('Error searching products:', error);
            productsContainer.innerHTML = '<p class="error">Failed to search products. Please try again later.</p>';
        }
    }
    
    // Function to display products
    function displayProducts(products) {
        // Clear products container
        productsContainer.innerHTML = '';
        
        if (products.length === 0) {
            productsContainer.innerHTML = '<p class="no-results">No products found matching your criteria.</p>';
            return;
        }
        
        // Create product cards
        products.forEach(product => {
            const productCard = createProductCard(product);
            productsContainer.appendChild(productCard);
        });
    }
    
    // Function to create a product card
    function createProductCard(product) {
        const card = document.createElement('div');
        card.className = 'product-card';
        
        // Use a placeholder image if image_url is not available
        const imageUrl = product.image_url || 'https://via.placeholder.com/300x200?text=AppleBite';
        
        card.innerHTML = `
            <div class="product-image">
                <img src="${imageUrl}" alt="${product.name}">
            </div>
            <div class="product-info">
                <h3 class="product-name">${product.name}</h3>
                <p class="product-price">$${product.price.toFixed(2)}</p>
                <p class="product-category">${product.category}</p>
                <p class="product-description">${product.description || ''}</p>
                <button class="btn add-to-cart" data-id="${product.id}" data-name="${product.name}" data-price="${product.price}">
                    Add to Cart
                </button>
            </div>
        `;
        
        return card;
    }
    
    // Function to initialize cart
    function initCart() {
        // Load cart from localStorage
        let cart = JSON.parse(localStorage.getItem('cart')) || [];
        
        // Update cart count
        updateCartCount(cart);
        
        // Add event delegation for add-to-cart buttons
        document.addEventListener('click', function(event) {
            if (event.target.classList.contains('add-to-cart')) {
                const button = event.target;
                const id = button.getAttribute('data-id');
                const name = button.getAttribute('data-name');
                const price = parseFloat(button.getAttribute('data-price'));
                
                addToCart({ id, name, price });
            }
        });
    }
    
    // Function to add item to cart
    function addToCart(product) {
        // Get current cart
        let cart = JSON.parse(localStorage.getItem('cart')) || [];
        
        // Check if product already exists in cart
        const existingProductIndex = cart.findIndex(item => item.id === product.id);
        
        if (existingProductIndex >= 0) {
            // Increment quantity
            cart[existingProductIndex].quantity += 1;
        } else {
            // Add new product to cart
            cart.push({
                id: product.id,
                name: product.name,
                price: product.price,
                quantity: 1
            });
        }
        
        // Save cart to localStorage
        localStorage.setItem('cart', JSON.stringify(cart));
        
        // Update cart count
        updateCartCount(cart);
        
        // Show confirmation message
        showMessage(`${product.name} added to cart!`);
    }
    
    // Function to update cart count
    function updateCartCount(cart) {
        const totalItems = cart.reduce((total, item) => total + item.quantity, 0);
        document.getElementById('cart-count').textContent = totalItems;
    }
    
    // Function to show message
    function showMessage(message) {
        // Create message element
        const messageElement = document.createElement('div');
        messageElement.className = 'message';
        messageElement.textContent = message;
        
        // Add to DOM
        document.body.appendChild(messageElement);
        
        // Animate in
        setTimeout(() => {
            messageElement.classList.add('show');
        }, 10);
        
        // Remove after delay
        setTimeout(() => {
            messageElement.classList.remove('show');
            setTimeout(() => {
                document.body.removeChild(messageElement);
            }, 300);
        }, 3000);
    }
});