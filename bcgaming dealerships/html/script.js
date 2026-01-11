// BCGAMING Dealership UI Script

let vehicles = [];
let categories = [];
let currentCategory = 'all';
let currentVehicle = null;
let playerMoney = 0;
let dealershipData = null;
let resourceName = '';
let financeConfig = null;
let currentCameraIndex = 0;
let financeEnabled = false;

// Listen for messages from client.lua
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.action) {
        case 'openDealership':
            openDealership(data);
            break;
        case 'closeDealership':
            closeDealership();
            break;
        case 'setPlayerMoney':
            setPlayerMoney(data.money);
            break;
    }
});

// Open dealership
function openDealership(data) {
    vehicles = data.vehicles || [];
    categories = data.categories || [];
    dealershipData = data.dealership || null;
    resourceName = data.resourceName || 'bcgaming-dealership';
    financeConfig = data.finance || null;
    
    document.getElementById('dealership-container').classList.remove('hidden');
    
    if (dealershipData) {
        document.getElementById('dealership-name').textContent = dealershipData.name;
        
        // Show camera controls if showroom is enabled
        if (dealershipData.showroom && dealershipData.showroom.enabled && dealershipData.showroom.camera) {
            document.getElementById('camera-controls').classList.remove('hidden');
            currentCameraIndex = 0;
            updateCameraIndicator();
        }
    }
    
    // Show finance section if enabled
    if (financeConfig && financeConfig.enabled) {
        document.getElementById('finance-section').classList.remove('hidden');
        setupFinanceControls();
    }
    
    renderCategories();
    renderVehicles();
}

// Close dealership
function closeDealership() {
    document.getElementById('dealership-container').classList.add('hidden');
    document.getElementById('vehicle-grid').classList.remove('hidden');
    document.getElementById('vehicle-details').classList.add('hidden');
    currentVehicle = null;
}

// Set player money
function setPlayerMoney(money) {
    playerMoney = money;
    document.getElementById('player-money').textContent = formatMoney(money);
}

// Render categories
function renderCategories() {
    const categoriesContainer = document.querySelector('.categories');
    const allBtn = categoriesContainer.querySelector('[data-category="all"]');
    
    categories.forEach(category => {
        const btn = document.createElement('button');
        btn.className = 'category-btn';
        btn.textContent = category;
        btn.setAttribute('data-category', category);
        btn.addEventListener('click', () => filterByCategory(category));
        categoriesContainer.appendChild(btn);
    });
}

// Filter by category
function filterByCategory(category) {
    currentCategory = category;
    
    // Update active button
    document.querySelectorAll('.category-btn').forEach(btn => {
        btn.classList.remove('active');
        if (btn.getAttribute('data-category') === category) {
            btn.classList.add('active');
        }
    });
    
    renderVehicles();
}

// Render vehicles
function renderVehicles() {
    const vehicleGrid = document.getElementById('vehicle-grid');
    vehicleGrid.innerHTML = '';
    
    const filteredVehicles = currentCategory === 'all' 
        ? vehicles 
        : vehicles.filter(v => v.category === currentCategory);
    
    filteredVehicles.forEach(vehicle => {
        const card = createVehicleCard(vehicle);
        vehicleGrid.appendChild(card);
    });
}

// Create vehicle card
function createVehicleCard(vehicle) {
    const card = document.createElement('div');
    card.className = 'vehicle-card';
    
    if (vehicle.stock !== undefined && vehicle.stock <= 0) {
        card.classList.add('out-of-stock');
    }
    
    card.innerHTML = `
        <div class="vehicle-name">${vehicle.name}</div>
        <div class="vehicle-price">${formatMoney(vehicle.price)}</div>
        <div class="vehicle-category">${vehicle.category}</div>
        ${vehicle.stock !== undefined ? `<div class="vehicle-stock">Stock: ${vehicle.stock}</div>` : ''}
    `;
    
    if (!(vehicle.stock !== undefined && vehicle.stock <= 0)) {
        card.addEventListener('click', () => showVehicleDetails(vehicle));
    }
    
    return card;
}

// Show vehicle details
function showVehicleDetails(vehicle) {
    currentVehicle = vehicle;
    
    document.getElementById('vehicle-grid').classList.add('hidden');
    document.getElementById('vehicle-details').classList.remove('hidden');
    
    document.getElementById('detail-name').textContent = vehicle.name;
    document.getElementById('detail-price').textContent = formatMoney(vehicle.price);
    document.getElementById('detail-category').textContent = vehicle.category;
    document.getElementById('detail-stock').textContent = vehicle.stock !== undefined ? vehicle.stock : 'Unlimited';
    
    const buyBtn = document.getElementById('buy-btn');
    const financeBuyBtn = document.getElementById('finance-buy-btn');
    
    if (vehicle.price > playerMoney) {
        buyBtn.disabled = true;
        buyBtn.textContent = 'Insufficient Funds';
        
        // Show finance button if finance is enabled
        if (financeConfig && financeConfig.enabled) {
            financeBuyBtn.classList.remove('hidden');
            updateFinanceCalculations();
        }
    } else {
        buyBtn.disabled = false;
        buyBtn.textContent = 'Purchase';
        financeBuyBtn.classList.add('hidden');
    }
    
    // Reset finance toggle
    financeEnabled = false;
    document.getElementById('finance-toggle').checked = false;
    updateFinanceDisplay();
}

// Setup finance controls
function setupFinanceControls() {
    if (!financeConfig) return;
    
    const downPaymentSlider = document.getElementById('down-payment-slider');
    const paymentPeriodSlider = document.getElementById('payment-period-slider');
    const financeToggle = document.getElementById('finance-toggle');
    
    downPaymentSlider.min = financeConfig.minDownPayment;
    downPaymentSlider.max = financeConfig.maxDownPayment;
    downPaymentSlider.value = financeConfig.defaultDownPayment;
    
    paymentPeriodSlider.min = financeConfig.minPaymentPeriods;
    paymentPeriodSlider.max = financeConfig.maxPaymentPeriods;
    paymentPeriodSlider.value = financeConfig.defaultPaymentPeriods;
    
    downPaymentSlider.addEventListener('input', () => {
        document.getElementById('down-payment-value').textContent = downPaymentSlider.value + '%';
        updateFinanceCalculations();
    });
    
    paymentPeriodSlider.addEventListener('input', () => {
        document.getElementById('payment-period-value').textContent = paymentPeriodSlider.value + ' months';
        updateFinanceCalculations();
    });
    
    financeToggle.addEventListener('change', () => {
        financeEnabled = financeToggle.checked;
        updateFinanceDisplay();
    });
}

// Update finance calculations
function updateFinanceCalculations() {
    if (!currentVehicle || !financeConfig) return;
    
    const downPaymentPercent = parseInt(document.getElementById('down-payment-slider').value);
    const paymentPeriods = parseInt(document.getElementById('payment-period-slider').value);
    
    const downPaymentAmount = Math.floor(currentVehicle.price * (downPaymentPercent / 100));
    const financeAmount = currentVehicle.price - downPaymentAmount;
    const interestAmount = Math.floor(financeAmount * (financeConfig.interestRate / 100));
    const totalFinanceAmount = financeAmount + interestAmount;
    const monthlyPayment = Math.floor(totalFinanceAmount / paymentPeriods);
    
    document.getElementById('calc-down-payment').textContent = formatMoney(downPaymentAmount);
    document.getElementById('calc-monthly-payment').textContent = formatMoney(monthlyPayment);
    document.getElementById('calc-total-finance').textContent = formatMoney(totalFinanceAmount);
}

// Update finance display
function updateFinanceDisplay() {
    const financeOptions = document.getElementById('finance-options');
    const buyBtn = document.getElementById('buy-btn');
    const financeBuyBtn = document.getElementById('finance-buy-btn');
    
    if (financeEnabled) {
        financeOptions.style.display = 'block';
        buyBtn.classList.add('hidden');
        financeBuyBtn.classList.remove('hidden');
        updateFinanceCalculations();
    } else {
        financeOptions.style.display = 'none';
        buyBtn.classList.remove('hidden');
        financeBuyBtn.classList.add('hidden');
    }
}

// Camera controls
function updateCameraIndicator() {
    if (dealershipData && dealershipData.showroom && dealershipData.showroom.camera) {
        const totalCameras = dealershipData.showroom.camera.length;
        document.getElementById('camera-indicator').textContent = `Camera ${currentCameraIndex + 1}/${totalCameras}`;
    }
}

// Camera navigation
document.getElementById('camera-prev')?.addEventListener('click', () => {
    if (dealershipData && dealershipData.showroom && dealershipData.showroom.camera) {
        currentCameraIndex = (currentCameraIndex - 1 + dealershipData.showroom.camera.length) % dealershipData.showroom.camera.length;
        updateCameraIndicator();
        fetch(`https://${GetParentResourceName()}/changeCamera`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({index: currentCameraIndex + 1})
        });
    }
});

document.getElementById('camera-next')?.addEventListener('click', () => {
    if (dealershipData && dealershipData.showroom && dealershipData.showroom.camera) {
        currentCameraIndex = (currentCameraIndex + 1) % dealershipData.showroom.camera.length;
        updateCameraIndicator();
        fetch(`https://${GetParentResourceName()}/changeCamera`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({index: currentCameraIndex + 1})
        });
    }
});

document.getElementById('camera-reset')?.addEventListener('click', () => {
    currentCameraIndex = 0;
    updateCameraIndicator();
    fetch(`https://${GetParentResourceName()}/resetCamera`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({})
    });
});

// Finance buy button
document.getElementById('finance-buy-btn')?.addEventListener('click', () => {
    if (currentVehicle && financeConfig && financeEnabled) {
        const downPaymentPercent = parseInt(document.getElementById('down-payment-slider').value);
        const paymentPeriods = parseInt(document.getElementById('payment-period-slider').value);
        
        const downPaymentAmount = Math.floor(currentVehicle.price * (downPaymentPercent / 100));
        
        if (playerMoney < downPaymentAmount) {
            alert('Insufficient funds for down payment!');
            return;
        }
        
        if (confirm(`Finance ${currentVehicle.name}?\nDown Payment: ${formatMoney(downPaymentAmount)}\nMonthly Payment: ${document.getElementById('calc-monthly-payment').textContent}\nPeriod: ${paymentPeriods} months`)) {
            fetch(`https://${GetParentResourceName()}/buyVehicle`, {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({
                    model: currentVehicle.model,
                    price: currentVehicle.price,
                    finance: true,
                    downPayment: downPaymentPercent,
                    paymentPeriods: paymentPeriods,
                    dealershipLocation: dealershipData ? {
                        x: dealershipData.location.x,
                        y: dealershipData.location.y,
                        z: dealershipData.location.z,
                        heading: dealershipData.heading
                    } : null
                })
            });
            closeDealership();
        }
    }
});

// Back button
document.getElementById('back-btn').addEventListener('click', () => {
    document.getElementById('vehicle-grid').classList.remove('hidden');
    document.getElementById('vehicle-details').classList.add('hidden');
    currentVehicle = null;
});

// Close button
document.getElementById('close-btn').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
    closeDealership();
});

// Preview button
document.getElementById('preview-btn').addEventListener('click', () => {
    if (currentVehicle) {
        fetch(`https://${GetParentResourceName()}/previewVehicle`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                model: currentVehicle.model
            })
        });
    }
});

// Stop preview (can be triggered from outside or by clicking preview again)
document.addEventListener('click', (e) => {
    if (e.target.closest('.preview-btn')) {
        // Preview logic handled above
    }
});

// Test drive button
document.getElementById('testdrive-btn').addEventListener('click', () => {
    if (currentVehicle) {
        fetch(`https://${GetParentResourceName()}/testDrive`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                model: currentVehicle.model
            })
        });
        closeDealership();
    }
});

// Buy button
document.getElementById('buy-btn').addEventListener('click', () => {
    if (currentVehicle && playerMoney >= currentVehicle.price) {
        if (confirm(`Are you sure you want to purchase ${currentVehicle.name} for ${formatMoney(currentVehicle.price)}?`)) {
            fetch(`https://${GetParentResourceName()}/buyVehicle`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    model: currentVehicle.model,
                    price: currentVehicle.price,
                    dealershipLocation: dealershipData ? {
                        x: dealershipData.location.x,
                        y: dealershipData.location.y,
                        z: dealershipData.location.z,
                        heading: dealershipData.heading
                    } : null
                })
            });
            closeDealership();
        }
    }
});

// Format money
function formatMoney(amount) {
    return '$' + amount.toLocaleString('en-US');
}

// Get parent resource name (for NUI callbacks)
function GetParentResourceName() {
    return resourceName || 'bcgaming-dealership';
}

// ESC key to close
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({})
        });
        closeDealership();
    }
});
