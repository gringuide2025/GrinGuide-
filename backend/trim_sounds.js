const ffmpeg = require('fluent-ffmpeg');
const ffmpegPath = require('ffmpeg-static');
const fs = require('fs');
const path = require('path');

ffmpeg.setFfmpegPath(ffmpegPath);

const assetDir = path.join(__dirname, '../assets/audio');
const resDir = path.join(__dirname, '../android/app/src/main/res/raw');

// Ensure resDir exists
if (!fs.existsSync(resDir)) {
    fs.mkdirSync(resDir, { recursive: true });
}

fs.readdir(assetDir, (err, files) => {
    if (err) {
        console.error('Could not list directory', err);
        return;
    }

    files.forEach(file => {
        if (path.extname(file) === '.mp3') {
            const inputPath = path.join(assetDir, file);
            const outputPath = path.join(resDir, file); // Write directly to Android res

            console.log(`Trimming ${file} to 1.5s...`);

            ffmpeg(inputPath)
                .setStartTime(0)
                .setDuration(1.5)
                .output(outputPath)
                .on('end', async function () {
                    console.log(`Finished processing ${file}`);
                    // Also update the asset copy so preview is short too
                    // Copy from resDir back to assetDir
                    try {
                        await fs.promises.copyFile(outputPath, inputPath);
                        console.log(`Updated asset for ${file}`);
                    } catch (e) {
                        console.error(`Failed to update asset ${file}`, e);
                    }
                })
                .on('error', function (err) {
                    console.error(`Error processing ${file}:`, err);
                })
                .run();
        }
    });
});
