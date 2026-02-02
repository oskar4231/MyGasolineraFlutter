
const fs = require('fs');
const path = require('path');

const basePath = 'C:\\Users\\carvaldel\\Desktop\\Proyectos\\Proyecto final\\Mygasolinera Frontend';
const modelosPath = path.join(basePath, 'modelos.json');
const motorizacionesPath = path.join(basePath, 'motorizaciones.json');
const marcasPath = path.join(basePath, 'marcas.json');

try {
    const marcas = JSON.parse(fs.readFileSync(marcasPath, 'utf8'));
    const modelos = JSON.parse(fs.readFileSync(modelosPath, 'utf8'));
    const motorizaciones = JSON.parse(fs.readFileSync(motorizacionesPath, 'utf8'));

    console.log(`Marcas count: ${marcas.length}`);
    console.log(`Modelos count: ${modelos.length}`);
    console.log(`Motorizaciones count: ${motorizaciones.length}`);

    // 1. Check duplicate IDs
    const checkUniqueIds = (items, name) => {
        const ids = new Set();
        items.forEach(item => {
            if (ids.has(item.id)) {
                console.error(`Duplicate ID found in ${name}: ${item.id}`);
            }
            ids.add(item.id);
        });
    };

    checkUniqueIds(marcas, 'marcas');
    checkUniqueIds(modelos, 'modelos');
    checkUniqueIds(motorizaciones, 'motorizaciones');

    // 2. Check foreign keys
    const marcaIds = new Set(marcas.map(m => m.id));
    modelos.forEach(modelo => {
        if (!marcaIds.has(modelo.marca_id)) {
            console.error(`Model ${modelo.id} references non-existent marca_id: ${modelo.marca_id}`);
        }
    });

    const modeloIds = new Set(modelos.map(m => m.id));
    const modelsWithEngines = new Set();
    motorizaciones.forEach(motor => {
        if (!modeloIds.has(motor.modelo_id)) {
            console.error(`Engine ${motor.id} references non-existent modelo_id: ${motor.modelo_id}`);
        }
        modelsWithEngines.add(motor.modelo_id);
    });

    // 3. Models without engines
    let modelsWithoutEnginesCount = 0;
    modelos.forEach(modelo => {
        if (!modelsWithEngines.has(modelo.id)) {
            console.warn(`Model ${modelo.id} (${modelo.nombre}) has no engines.`);
            modelsWithoutEnginesCount++;
        }
    });

    if (modelsWithoutEnginesCount === 0) {
        console.log("All models have at least one engine.");
    } else {
        console.log(`${modelsWithoutEnginesCount} models have no engines.`);
    }

    console.log('Verification complete.');

} catch (err) {
    console.error('Error reading or parsing files:', err);
}
