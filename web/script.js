// desync-lib UI System - Vanilla JS for RedM
class DesyncUI {
    constructor() {
        this.notifications = [];
        this.activeProgress = null;
        this.worldTexts = new Map();
        this.nextTextId = 1;

        this.init();
    }

    init() {
        // Listen for NUI messages from Lua
        window.addEventListener('message', this.handleMessage.bind(this));

        // Send ready signal to Lua
        this.sendToLua('ready');
    }

    handleMessage(event) {
        const data = event.data;

        switch (data.action) {
            case 'showNotification':
                this.showNotification(data);
                break;
            case 'showProgressBar':
                this.showProgressBar(data);
                break;
            case 'showProgressCircle':
                this.showProgressCircle(data);
                break;
            case 'updateProgress':
                this.updateProgress(data);
                break;
            case 'hideProgress':
                this.hideProgress();
                break;
            case 'showWorldText':
                this.showWorldText(data);
                break;
            case 'updateWorldText':
                this.updateWorldText(data);
                break;
            case 'hideWorldText':
                this.hideWorldText(data);
                break;
            case 'clearWorldTexts':
                this.clearWorldTexts();
                break;
        }
    }

    sendToLua(action, data = {}) {
        fetch(`https://desync-lib/${action}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        });
    }

    // Notification System
    showNotification(data) {
        const notification = document.createElement('div');
        notification.className = `notification ${data.type || 'info'} fade-in`;
        notification.innerHTML = `
            <div class="notification-title">${data.title || 'Notification'}</div>
            <div class="notification-description">${data.description || ''}</div>
        `;

        const container = document.getElementById('notifications');
        container.appendChild(notification);

        // Auto-hide after duration
        const duration = data.duration || 5000;
        setTimeout(() => {
            this.hideNotification(notification);
        }, duration);

        // Store reference for manual hiding
        this.notifications.push(notification);
    }

    hideNotification(notification) {
        notification.classList.add('fade-out');
        setTimeout(() => {
            if (notification.parentNode) {
                notification.parentNode.removeChild(notification);
            }
            // Remove from array
            const index = this.notifications.indexOf(notification);
            if (index > -1) {
                this.notifications.splice(index, 1);
            }
        }, 300);
    }

    // Progress Bar System
    showProgressBar(data) {
        this.hideProgress(); // Hide any existing progress

        const container = document.getElementById('progress-container');
        const bar = document.getElementById('progress-bar');
        const fill = bar.querySelector('.progress-fill');
        const text = bar.querySelector('.progress-text');

        text.textContent = data.label || 'Loading...';
        fill.style.width = '0%';

        container.style.display = 'block';
        bar.style.display = 'block';
        document.getElementById('progress-circle').style.display = 'none';

        this.activeProgress = {
            type: 'bar',
            element: bar,
            fill: fill,
            text: text,
            canCancel: data.canCancel || false
        };

        // Handle cancellation
        if (data.canCancel) {
            bar.style.cursor = 'pointer';
            bar.addEventListener('click', () => {
                this.sendToLua('progressCancelled');
                this.hideProgress();
            });
        }
    }

    showProgressCircle(data) {
        this.hideProgress(); // Hide any existing progress

        const container = document.getElementById('progress-container');
        const circle = document.getElementById('progress-circle');
        const text = circle.querySelector('.progress-circle-text');
        const ring = circle.querySelector('.progress-ring-fill');

        text.textContent = '0%';
        ring.style.strokeDashoffset = '339.292'; // Full circle

        container.style.display = 'block';
        circle.style.display = 'block';
        document.getElementById('progress-bar').style.display = 'none';

        this.activeProgress = {
            type: 'circle',
            element: circle,
            text: text,
            ring: ring,
            canCancel: data.canCancel || false
        };

        // Handle cancellation
        if (data.canCancel) {
            circle.style.cursor = 'pointer';
            circle.addEventListener('click', () => {
                this.sendToLua('progressCancelled');
                this.hideProgress();
            });
        }
    }

    updateProgress(data) {
        if (!this.activeProgress) return;

        const progress = Math.max(0, Math.min(100, data.progress || 0));

        if (this.activeProgress.type === 'bar') {
            this.activeProgress.fill.style.width = `${progress}%`;
            if (data.label) {
                this.activeProgress.text.textContent = data.label;
            }
        } else if (this.activeProgress.type === 'circle') {
            const circumference = 339.292; // 2 * π * 54
            const offset = circumference - (progress / 100) * circumference;
            this.activeProgress.ring.style.strokeDashoffset = offset;
            this.activeProgress.text.textContent = `${Math.round(progress)}%`;
        }
    }

    hideProgress() {
        if (!this.activeProgress) return;

        const container = document.getElementById('progress-container');
        container.style.display = 'none';

        this.activeProgress.element.style.display = 'none';
        this.activeProgress = null;
    }

    // 3D World Text System
    showWorldText(data) {
        const textId = this.nextTextId++;
        const textElement = document.createElement('div');

        textElement.className = `world-text ${data.size || 'medium'} ${data.color || 'white'}`;
        textElement.textContent = data.text || '';
        textElement.style.left = `${data.screenX || 50}%`;
        textElement.style.top = `${data.screenY || 50}%`;

        document.getElementById('world-text-container').appendChild(textElement);

        this.worldTexts.set(textId, {
            element: textElement,
            data: data
        });

        // Auto-hide if duration specified
        if (data.duration) {
            setTimeout(() => {
                this.hideWorldText({ id: textId });
            }, data.duration);
        }

        return textId;
    }

    updateWorldText(data) {
        const textData = this.worldTexts.get(data.id);
        if (!textData) return;

        if (data.text !== undefined) {
            textData.element.textContent = data.text;
        }

        if (data.screenX !== undefined) {
            textData.element.style.left = `${data.screenX}%`;
        }

        if (data.screenY !== undefined) {
            textData.element.style.top = `${data.screenY}%`;
        }

        if (data.size) {
            textData.element.className = textData.element.className.replace(/small|medium|large/g, data.size);
        }

        if (data.color) {
            textData.element.className = textData.element.className.replace(/red|green|blue|yellow|white/g, data.color);
        }

        textData.data = { ...textData.data, ...data };
    }

    hideWorldText(data) {
        const textData = this.worldTexts.get(data.id);
        if (!textData) return;

        textData.element.remove();
        this.worldTexts.delete(data.id);
    }

    clearWorldTexts() {
        const container = document.getElementById('world-text-container');
        container.innerHTML = '';
        this.worldTexts.clear();
    }
}

// Initialize the UI system when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    window.desyncUI = new DesyncUI();
});

// Export for potential external use
window.DesyncUI = DesyncUI;
