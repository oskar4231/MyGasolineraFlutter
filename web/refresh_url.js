/**
 * Comando para recargar la URL del backend desde la consola del navegador
 * 
 * Uso desde la consola:
 *   refreshBackendUrl()
 * 
 * Esto forzará una actualización inmediata de la URL del backend
 * sin revisar el caché, obteniendo la URL directamente del Gist.
 */

window.refreshBackendUrl = function () {
    console.log('🔄 Forzando actualización de URL del backend...');

    try {
        // Enviar mensaje a Flutter usando postMessage
        window.postMessage({
            type: 'REFRESH_BACKEND_URL',
            source: 'console'
        }, '*');

        console.log('✅ Comando enviado. La URL se actualizará en unos segundos.');
        console.log('💡 Revisa la consola de Flutter para ver el progreso.');
    } catch (e) {
        console.error('❌ Error al enviar comando:', e);
    }
};

// Mensaje de bienvenida cuando se carga la página
window.addEventListener('load', function () {
    setTimeout(function () {
        console.log('%c🚀 MyGasolinera - Comandos disponibles:', 'color: #4CAF50; font-weight: bold; font-size: 14px;');
        console.log('%crefreshBackendUrl()%c - Fuerza la actualización de la URL del backend', 'color: #2196F3; font-weight: bold;', 'color: inherit;');
    }, 1000);
});
