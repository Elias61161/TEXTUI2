(function() {
    'use strict';

    const Icons = {
        'door': '🚪', 'unlock': '🔓', 'lock': '🔒', 'key': '🔑',
        'info': 'ℹ️', 'bank': '🏦', 'money': '💰', 'dollar': '💲',
        'car': '🚗', 'user': '👤', 'users': '👥', 'phone': '📱',
        'home': '🏠', 'shop': '🏪', 'food': '🍔', 'drink': '🥤',
        'medical': '💊', 'hospital': '🏥', 'police': '👮', 'mechanic': '🔧',
        'wrench': '🔧', 'gas': '⛽', 'box': '📦', 'clothing': '👕',
        'scissors': '✂️', 'gym': '💪', 'credit-card': '💳', 'card': '💳',
        'atm': '🏧', 'eye': '👁️', 'search': '🔍', 'cog': '⚙️',
        'check': '✅', 'times': '❌', 'plus': '➕', 'hand': '✋',
        'clipboard': '📋', 'file': '📄', 'default': '•'
    };

    function getIcon(name) {
        if (!name) return '';
        return Icons[name.toLowerCase()] || Icons['default'];
    }

    // DOM
    const simpleTextUI = document.getElementById('simpleTextUI');
    const simpleKey = document.getElementById('simpleKey');
    const simpleText = document.getElementById('simpleText');
    const marker = document.getElementById('marker');
    const optionsMenu = document.getElementById('optionsMenu');
    const optionsList = document.getElementById('optionsList');
    const scrollIndicator = document.getElementById('scrollIndicator');
    const scrollDots = document.getElementById('scrollDots');

    // State
    let currentOptions = [];
    let selectedIndex = 1;
    let currentPointId = null;
    let lastState = 'none';
    let isTransitioning = false;
    let isAnimating = false;

    function GetParentResourceName() {
        return window.GetParentResourceName ? window.GetParentResourceName() : 'qs-textui';
    }

    // Simple Text UI
    function showSimpleText(data) {
        if (data.key) {
            simpleKey.textContent = data.key;
            simpleKey.parentElement.style.display = 'flex';
        } else {
            simpleKey.parentElement.style.display = 'none';
        }
        simpleText.textContent = data.text || 'Interact';
        simpleTextUI.classList.remove('hidden');
    }

    function hideSimpleText() {
        simpleTextUI.classList.add('hidden');
    }

    // Marker
    function showMarker(data) {
        marker.style.left = (data.x * 100) + '%';
        marker.style.top = (data.y * 100) + '%';
        
        if (lastState === 'options' && !isTransitioning) {
            isTransitioning = true;
            optionsMenu.classList.add('animate-out');
            
            setTimeout(() => {
                optionsMenu.classList.add('hidden');
                optionsMenu.classList.remove('animate-out');
                marker.classList.remove('hidden', 'animate-out');
                marker.classList.add('animate-in');
                
                setTimeout(() => {
                    marker.classList.remove('animate-in');
                    isTransitioning = false;
                }, 300);
            }, 250);
        } else if (lastState !== 'marker') {
            marker.classList.remove('hidden');
        }
        
        lastState = 'marker';
    }

    function hideMarker() {
        marker.classList.add('hidden');
        marker.classList.remove('animate-in', 'animate-out');
    }

    // Scroll Indicator
    function updateScrollIndicator(total, selected) {
        if (total <= 1) {
            scrollIndicator.classList.add('hidden');
            return;
        }

        scrollIndicator.classList.remove('hidden');
        
        // Update arrows - disable if at bounds
        const upArrow = scrollIndicator.querySelector('.arrow.up');
        const downArrow = scrollIndicator.querySelector('.arrow.down');
        
        if (upArrow) {
            if (selected <= 1) {
                upArrow.classList.add('disabled');
            } else {
                upArrow.classList.remove('disabled');
            }
        }
        
        if (downArrow) {
            if (selected >= total) {
                downArrow.classList.add('disabled');
            } else {
                downArrow.classList.remove('disabled');
            }
        }
        
        // Update dots
        scrollDots.innerHTML = '';
        for (let i = 1; i <= total; i++) {
            const dot = document.createElement('div');
            dot.className = 'scroll-dot' + (i === selected ? ' active' : '');
            dot.dataset.index = i;
            
            dot.addEventListener('click', () => {
                if (i !== selectedIndex && !isAnimating) {
                    scrollTo(i);
                    sendScroll(i);
                }
            });
            
            scrollDots.appendChild(dot);
        }
    }

    function updateDots(selected) {
        const dots = scrollDots.querySelectorAll('.scroll-dot');
        dots.forEach((dot, idx) => {
            dot.classList.toggle('active', (idx + 1) === selected);
        });
        
        // Update arrows
        const upArrow = scrollIndicator.querySelector('.arrow.up');
        const downArrow = scrollIndicator.querySelector('.arrow.down');
        
        if (upArrow) {
            upArrow.classList.toggle('disabled', selected <= 1);
        }
        if (downArrow) {
            downArrow.classList.toggle('disabled', selected >= currentOptions.length);
        }
    }

    // Options
    function showOptions(data) {
        currentPointId = data.id;
        currentOptions = data.options || [];
        selectedIndex = data.selectedIndex || 1;
        
        if (selectedIndex > currentOptions.length) selectedIndex = 1;
        
        optionsMenu.style.left = (data.x * 100) + '%';
        optionsMenu.style.top = (data.y * 100) + '%';
        
        buildOptions();
        
        if (lastState === 'marker' && !isTransitioning) {
            isTransitioning = true;
            marker.classList.add('animate-out');
            
            setTimeout(() => {
                marker.classList.add('hidden');
                marker.classList.remove('animate-out');
                optionsMenu.classList.remove('hidden');
                optionsMenu.classList.add('animate-in');
                
                setTimeout(() => {
                    optionsMenu.classList.remove('animate-in');
                    isTransitioning = false;
                }, 300);
            }, 250);
        } else if (lastState !== 'options') {
            optionsMenu.classList.remove('hidden');
        }
        
        lastState = 'options';
    }

    function buildOptions() {
        optionsList.innerHTML = '';
        
        currentOptions.forEach((opt, idx) => {
            const index = idx + 1;
            const row = document.createElement('div');
            row.className = 'option-row';
            row.dataset.index = index;
            row.dataset.originalIndex = opt.index;
            
            if (index === selectedIndex) {
                row.classList.add('selected');
            } else {
                row.classList.add('dimmed');
            }
            
            const iconHtml = opt.icon ? `<span class="icon">${getIcon(opt.icon)}</span>` : '';
            
            row.innerHTML = `
                <div class="key-box">
                    <div class="key-inner">${opt.key || 'E'}</div>
                </div>
                <div class="text-box">
                    <div class="text-inner">
                        ${iconHtml}
                        <span class="label">${opt.label || 'Option'}</span>
                    </div>
                </div>
            `;
            
            row.addEventListener('click', (e) => {
                e.stopPropagation();
                fetch(`https://${GetParentResourceName()}/selectOption`, {
                    method: 'POST',
                    body: JSON.stringify({ id: currentPointId, index: opt.index })
                });
            });
            
            optionsList.appendChild(row);
        });
        
        updateScrollIndicator(currentOptions.length, selectedIndex);
    }

    // Scroll with Lunar Bridge animation
    function scrollTo(newIndex) {
        if (currentOptions.length === 0 || isAnimating) return;
        
        // Bound check - no wrap around!
        if (newIndex < 1 || newIndex > currentOptions.length) return;
        if (newIndex === selectedIndex) return;
        
        isAnimating = true;
        
        const oldIndex = selectedIndex;
        selectedIndex = newIndex;
        
        const rows = optionsList.querySelectorAll('.option-row');
        
        rows.forEach((row) => {
            const index = parseInt(row.dataset.index);
            
            // Remove previous states
            row.classList.remove('selected', 'dimmed', 'selecting', 'deselecting');
            
            if (index === selectedIndex) {
                // New selected - animate in
                row.classList.add('selecting');
                
                setTimeout(() => {
                    row.classList.remove('selecting');
                    row.classList.add('selected');
                }, 400);
                
            } else if (index === oldIndex) {
                // Old selected - animate out
                row.classList.add('deselecting');
                
                setTimeout(() => {
                    row.classList.remove('deselecting');
                    row.classList.add('dimmed');
                }, 400);
                
            } else {
                // Other items - just dimmed
                row.classList.add('dimmed');
            }
        });
        
        updateDots(selectedIndex);
        
        // Reset animation lock
        setTimeout(() => {
            isAnimating = false;
        }, 400);
    }

    function hideOptions() {
        optionsMenu.classList.add('hidden');
        optionsMenu.classList.remove('animate-in', 'animate-out');
        hideMarker();
        scrollIndicator.classList.add('hidden');
        currentOptions = [];
        selectedIndex = 1;
        currentPointId = null;
        lastState = 'none';
        isAnimating = false;
    }

    function sendScroll(index) {
        fetch(`https://${GetParentResourceName()}/scroll`, {
            method: 'POST',
            body: JSON.stringify({ index: index })
        });
    }

    // Mouse wheel scroll - WITH BOUNDS CHECK
    document.addEventListener('wheel', (e) => {
        if (currentOptions.length > 1 && !isAnimating) {
            e.preventDefault();
            
            let newIndex;
            
            if (e.deltaY > 0) {
                // Scrolling DOWN - only if not at bottom
                if (selectedIndex < currentOptions.length) {
                    newIndex = selectedIndex + 1;
                    scrollTo(newIndex);
                    sendScroll(selectedIndex);
                }
            } else {
                // Scrolling UP - only if not at top
                if (selectedIndex > 1) {
                    newIndex = selectedIndex - 1;
                    scrollTo(newIndex);
                    sendScroll(selectedIndex);
                }
            }
        }
    }, { passive: false });

    // Arrow clicks - WITH BOUNDS CHECK
    document.addEventListener('click', (e) => {
        if (e.target.classList.contains('arrow') && !e.target.classList.contains('disabled') && !isAnimating) {
            if (currentOptions.length > 1) {
                if (e.target.classList.contains('up') && selectedIndex > 1) {
                    scrollTo(selectedIndex - 1);
                    sendScroll(selectedIndex);
                } else if (e.target.classList.contains('down') && selectedIndex < currentOptions.length) {
                    scrollTo(selectedIndex + 1);
                    sendScroll(selectedIndex);
                }
            }
        }
    });

    // Message handler
    window.addEventListener('message', (event) => {
        const data = event.data;
        if (!data || !data.action) return;

        switch (data.action) {
            case 'showSimpleText':
                showSimpleText(data);
                break;
            case 'hideSimpleText':
                hideSimpleText();
                break;
            case 'showMarker':
                showMarker(data);
                break;
            case 'showOptions':
                showOptions(data);
                break;
            case 'updateSelection':
                scrollTo(data.selectedIndex);
                break;
            case 'hide':
                hideOptions();
                break;
            case 'hideAll':
                hideSimpleText();
                hideOptions();
                break;
            case 'setVisible':
                document.body.style.opacity = data.visible ? '1' : '0';
                break;
        }
    });

    // Init
    $(document).ready(() => {
        $.post(`https://${GetParentResourceName()}/getConfig`, JSON.stringify({}), (response) => {
            if (response && response.colors) {
                const c = response.colors;
                const root = document.documentElement;
                if (c.insideBackground) root.style.setProperty('--inside-background', c.insideBackground);
                if (c.insideBoxShadow) root.style.setProperty('--inside-box-shadow', c.insideBoxShadow);
                if (c.insideBorder) root.style.setProperty('--inside-border', c.insideBorder);
                if (c.backgroundAnimateColor) root.style.setProperty('--background-animate-color', c.backgroundAnimateColor);
            }
        });
    });

})();