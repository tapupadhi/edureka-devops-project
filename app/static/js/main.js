// Fetch products from the API
document.addEventListener('DOMContentLoaded', function() {
    // Load featured products
    const featuredProductsContainer = document.getElementById('featured-products');
    if (featuredProductsContainer) {
        fetchProducts();
    }

    // Initialize cart functionality
    initCart();
});

// Fetch products from the API
async function fetchProducts() {
    try {
        const response = await fetch('/api/products/');
        const products = await response.json();
        
        // Clear loading message
        const featuredProductsContainer = document.getElementById('featured-products');
        featuredProductsContainer.innerHTML = '';
        
        // Display up to 4 featured products
        const featuredProducts = products.slice(0, 4);
        
        featuredProducts.forEach(product => {
            const productCard = createProductCard(product);
            featuredProductsContainer.appendChild(productCard);
        });
    } catch (error) {
        console.error('Error fetching products:', error);
        document.getElementById('featured-products').innerHTML = 
            '<p class="error">Failed to load products. Please try again later.</p>';
    }
}

// Create a product card element
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
            <button class="btn add-to-cart" data-id="${product.id}" data-name="${product.name}" data-price="${product.price}">
                Add to Cart
            </button>
        </div>
    `;
    
    // Add event listener to the Add to Cart button
    card.querySelector('.add-to-cart').addEventListener('click', function() {
        const id = this.getAttribute('data-id');
        const name = this.getAttribute('data-name');
        const price = parseFloat(this.getAttribute('data-price'));
        
        addToCart({ id, name, price });
    });
    
    return card;
}

// Initialize cart functionality
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

// Add item to cart
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

// Update cart count in the header
function updateCartCount(cart) {
    const totalItems = cart.reduce((total, item) => total + item.quantity, 0);
    document.getElementById('cart-count').textContent = totalItems;
}

// Show message
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