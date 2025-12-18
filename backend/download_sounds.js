const fs = require('fs');
const path = require('path');
const https = require('https');

const sounds = [
    { name: 'sound_chime', url: 'https://notificationsounds.com/storage/sounds/file-sounds-1148-jingle-bells.mp3' },
    { name: 'sound_magic', url: 'https://notificationsounds.com/storage/sounds/file-sounds-1150-pristine.mp3' },
    { name: 'sound_pop', url: 'https://notificationsounds.com/storage/sounds/file-sounds-1101-plucky.mp3' },
    { name: 'sound_bird', url: 'https://notificationsounds.com/storage/sounds/file-sounds-1143-sharp.mp3' },
    { name: 'sound_power', url: 'https://notificationsounds.com/storage/sounds/file-sounds-1137-juntos.mp3' }
];

const download = (url, dest) => {
    return new Promise((resolve, reject) => {
        const file = fs.createWriteStream(dest);
        https.get(url, (response) => {
            response.pipe(file);
            file.on('finish', () => {
                file.close(resolve);
            });
        }).on('error', (err) => {
            fs.unlink(dest, () => { });
            reject(err);
        });
    });
};

async function run() {
    console.log("Downloading sounds...");

    for (const s of sounds) {
        const assetPath = path.join(__dirname, '../assets/audio', `${s.name}.mp3`);
        const resPath = path.join(__dirname, '../android/app/src/main/res/raw', `${s.name}.mp3`);

        try {
            console.log(`Downloading ${s.name}...`);
            await download(s.url, assetPath);
            fs.copyFileSync(assetPath, resPath);
            console.log(`Saved to assets and res/raw.`);
        } catch (e) {
            console.error(`Error downloading ${s.name}:`, e.message);
        }
    }
    console.log("Done.");
}

run();
