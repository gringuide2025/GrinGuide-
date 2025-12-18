const fs = require('fs');
const path = require('path');

function writeWav(filename, buffer) {
    fs.writeFileSync(filename, buffer);
    console.log(`Generated ${filename}`);
}

function createWavBuffer(sampleRate, durationSeconds, generateSample) {
    const numSamples = sampleRate * durationSeconds;
    const buffer = Buffer.alloc(44 + numSamples * 2);

    // WAV Header
    buffer.write('RIFF', 0);
    buffer.writeUInt32LE(36 + numSamples * 2, 4);
    buffer.write('WAVE', 8);
    buffer.write('fmt ', 12);
    buffer.writeUInt32LE(16, 16);
    buffer.writeUInt16LE(1, 20); // PCM
    buffer.writeUInt16LE(1, 22); // Mono
    buffer.writeUInt32LE(sampleRate, 24);
    buffer.writeUInt32LE(sampleRate * 2, 28);
    buffer.writeUInt16LE(2, 32);
    buffer.writeUInt16LE(16, 34); // 16-bit
    buffer.write('data', 36);
    buffer.writeUInt32LE(numSamples * 2, 40);

    // Data
    for (let i = 0; i < numSamples; i++) {
        const t = i / sampleRate;
        const sample = generateSample(t, i);
        // Clip to -1.0 to 1.0
        const clipped = Math.max(-1.0, Math.min(1.0, sample));
        const int16 = clipped < 0 ? clipped * 0x8000 : clipped * 0x7FFF;
        buffer.writeInt16LE(Math.floor(int16), 44 + i * 2);
    }

    return buffer;
}

const SAMPLE_RATE = 44100;

// 1. Chime: Simple sine decay
const chime = createWavBuffer(SAMPLE_RATE, 1.5, (t) => {
    const freq = 880;
    const envelope = Math.exp(-3 * t);
    return Math.sin(2 * Math.PI * freq * t) * envelope;
});

// 2. Magic: Sine glide up
const magic = createWavBuffer(SAMPLE_RATE, 1.0, (t) => {
    const freq = 400 + 1000 * t; // 400Hz -> 1400Hz
    const envelope = Math.min(1, 5 * t) * Math.min(1, 5 * (1 - t)); // smooth attack/decay
    return Math.sin(2 * Math.PI * freq * t) * envelope;
});

// 3. Pop: Short decaying burst
const pop = createWavBuffer(SAMPLE_RATE, 0.2, (t) => {
    const freq = 600 - 2000 * t; // Pitch drop
    const envelope = Math.exp(-20 * t);
    return Math.sin(2 * Math.PI * Math.max(100, freq) * t) * envelope;
});

// 4. Bird: FM Synthesis chirp
const bird = createWavBuffer(SAMPLE_RATE, 0.5, (t) => {
    const carrier = 2000;
    const modulator = 20;
    const modIndex = 500;
    const envelope = Math.min(1, 10 * t) * Math.min(1, 4 * (0.5 - t));
    return Math.sin(2 * Math.PI * carrier * t + modIndex * Math.sin(2 * Math.PI * modulator * t)) * envelope;
});

// 5. Power: Square wave arpeggio (C major)
const power = createWavBuffer(SAMPLE_RATE, 1.0, (t) => {
    let freq = 261.63; // C4
    if (t > 0.2) freq = 329.63; // E4
    if (t > 0.4) freq = 392.00; // G4
    if (t > 0.6) freq = 523.25; // C5

    const val = Math.sin(2 * Math.PI * freq * t) > 0 ? 0.5 : -0.5;
    const envelope = Math.min(1, 10 * t) * Math.min(1, 3 * (1 - t));
    return val * envelope;
});

async function run() {
    const assetDir = path.join(__dirname, '../assets/audio');
    const resDir = path.join(__dirname, '../android/app/src/main/res/raw');

    const sounds = [
        { name: 'sound_chime.wav', buffer: chime },
        { name: 'sound_magic.wav', buffer: magic },
        { name: 'sound_pop.wav', buffer: pop },
        { name: 'sound_bird.wav', buffer: bird },
        { name: 'sound_power.wav', buffer: power },
    ];

    for (const s of sounds) {
        writeWav(path.join(assetDir, s.name), s.buffer);
        writeWav(path.join(resDir, s.name), s.buffer);
    }
}

run();
