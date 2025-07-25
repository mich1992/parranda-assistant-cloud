class ChatApp {
    constructor() {
        this.conversationHistory = [];
        this.isTyping = false;
        
        this.initializeElements();
        this.attachEventListeners();
        this.checkServerHealth();
        
        // Auto focus en el input
        this.messageInput.focus();
    }

    initializeElements() {
        this.chatMessages = document.getElementById('chatMessages');
        this.messageInput = document.getElementById('messageInput');
        this.sendButton = document.getElementById('sendButton');
        this.typingIndicator = document.getElementById('typingIndicator');
        this.quickActions = document.getElementById('quickActions');
        this.loadingOverlay = document.getElementById('loadingOverlay');
    }

    attachEventListeners() {
        // Enviar mensaje con Enter
        this.messageInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                this.sendMessage();
            }
        });

        // Enviar mensaje con botón
        this.sendButton.addEventListener('click', () => {
            this.sendMessage();
        });

        // Botones de acciones rápidas
        this.quickActions.addEventListener('click', (e) => {
            if (e.target.classList.contains('quick-btn') || e.target.closest('.quick-btn')) {
                const button = e.target.classList.contains('quick-btn') ? e.target : e.target.closest('.quick-btn');
                const message = button.dataset.message;
                if (message) {
                    this.messageInput.value = message;
                    this.sendMessage();
                }
            }
        });

        // Auto-resize del input
        this.messageInput.addEventListener('input', () => {
            this.updateSendButton();
        });
    }

    updateSendButton() {
        const hasText = this.messageInput.value.trim().length > 0;
        this.sendButton.disabled = !hasText || this.isTyping;
    }

    async sendMessage() {
        const message = this.messageInput.value.trim();
        
        if (!message || this.isTyping) return;

        // Agregar mensaje del usuario
        this.addMessage(message, 'user');
        
        // Limpiar input
        this.messageInput.value = '';
        this.updateSendButton();

        // Ocultar acciones rápidas después del primer mensaje
        if (this.conversationHistory.length === 0) {
            this.quickActions.style.display = 'none';
        }

        // Mostrar indicador de escritura
        this.showTyping();

        try {
            const response = await this.sendToServer(message);
            
            // Ocultar indicador de escritura
            this.hideTyping();
            
            if (response.escalated) {
                // Mensaje de escalación con estilo especial
                this.addMessage(response.response, 'assistant', true);
            } else {
                // Mensaje normal
                this.addMessage(response.response, 'assistant');
            }

        } catch (error) {
            this.hideTyping();
            this.addMessage(
                '⚠️ Disculpa, hubo un problema conectando con el servidor. Por favor intenta de nuevo en unos momentos.',
                'assistant'
            );
            console.error('Error:', error);
        }
    }

    async sendToServer(message) {
        const response = await fetch('/api/chat', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                message: message,
                conversationHistory: this.conversationHistory
            })
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        return await response.json();
    }

    addMessage(content, sender, isEscalation = false) {
        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${sender}`;
        
        const currentTime = new Date().toLocaleTimeString('es-CO', {
            hour: '2-digit',
            minute: '2-digit'
        });

        const avatar = sender === 'user' ? '👤' : '🎵';
        
        messageDiv.innerHTML = `
            <div class="message-avatar">${avatar}</div>
            <div class="message-content">
                <div class="message-bubble ${isEscalation ? 'escalation-message' : ''}">
                    ${this.formatMessage(content)}
                </div>
                <div class="message-time">${currentTime}</div>
            </div>
        `;

        // Eliminar mensaje de bienvenida si existe
        const welcomeMessage = this.chatMessages.querySelector('.welcome-message');
        if (welcomeMessage && this.conversationHistory.length === 0) {
            welcomeMessage.remove();
        }

        this.chatMessages.appendChild(messageDiv);
        this.scrollToBottom();

        // Agregar al historial de conversación
        this.conversationHistory.push({
            role: sender === 'user' ? 'user' : 'assistant',
            content: content
        });

        // Mantener solo los últimos 20 mensajes en el historial
        if (this.conversationHistory.length > 20) {
            this.conversationHistory = this.conversationHistory.slice(-20);
        }
    }

    formatMessage(content) {
        // Convertir saltos de línea a <br>
        content = content.replace(/\n/g, '<br>');
        
        // Formatear precios
        content = content.replace(/\$[\d,]+/g, '<strong>$&</strong>');
        
        // Formatear emojis y iconos importantes
        content = content.replace(/(👨‍💼|🎵|📍|💰|✅|⚠️|🎬|🎶|🪗|🥁)/g, '<span class="emoji">$1</span>');
        
        return content;
    }

    showTyping() {
        this.isTyping = true;
        this.typingIndicator.style.display = 'flex';
        this.updateSendButton();
        this.scrollToBottom();
    }

    hideTyping() {
        this.isTyping = false;
        this.typingIndicator.style.display = 'none';
        this.updateSendButton();
    }

    scrollToBottom() {
        this.chatMessages.scrollTop = this.chatMessages.scrollHeight;
    }

    showLoading() {
        this.loadingOverlay.style.display = 'flex';
    }

    hideLoading() {
        this.loadingOverlay.style.display = 'none';
    }

    async checkServerHealth() {
        try {
            const response = await fetch('/api/health');
            const health = await response.json();
            
            if (!health.openai) {
                this.addMessage(
                    '⚠️ Advertencia: No se detectó configuración de OpenAI API. Algunos servicios pueden no funcionar correctamente.',
                    'assistant'
                );
            }
            
            console.log('Server health:', health);
        } catch (error) {
            console.warn('Could not check server health:', error);
        }
    }

    // Método para mostrar mensajes de estado
    showStatus(message, type = 'info') {
        const statusDiv = document.createElement('div');
        statusDiv.className = `status-message ${type}`;
        statusDiv.innerHTML = `
            <div class="status-content">
                <i class="fas fa-info-circle"></i>
                <span>${message}</span>
            </div>
        `;
        
        this.chatMessages.appendChild(statusDiv);
        this.scrollToBottom();
        
        // Auto-remove después de 5 segundos
        setTimeout(() => {
            if (statusDiv.parentNode) {
                statusDiv.remove();
            }
        }, 5000);
    }
}

// Inicializar la aplicación cuando el DOM esté listo
document.addEventListener('DOMContentLoaded', () => {
    window.chatApp = new ChatApp();
});

// Manejar errores globales
window.addEventListener('error', (e) => {
    console.error('Global error:', e.error);
});

// Manejar errores de promesas no capturadas
window.addEventListener('unhandledrejection', (e) => {
    console.error('Unhandled promise rejection:', e.reason);
});

// CSS adicional para emojis y estados
const additionalStyles = `
    .emoji {
        font-size: 1.1em;
    }
    
    .status-message {
        text-align: center;
        margin: 10px 0;
        padding: 8px 16px;
        border-radius: 20px;
        font-size: 0.9rem;
    }
    
    .status-message.info {
        background: #e0f2fe;
        color: #0277bd;
        border: 1px solid #81d4fa;
    }
    
    .status-message.warning {
        background: #fff8e1;
        color: #f57c00;
        border: 1px solid #ffcc02;
    }
    
    .status-content {
        display: flex;
        align-items: center;
        gap: 8px;
        justify-content: center;
    }
`;

// Agregar estilos adicionales
const styleSheet = document.createElement('style');
styleSheet.textContent = additionalStyles;
document.head.appendChild(styleSheet); 