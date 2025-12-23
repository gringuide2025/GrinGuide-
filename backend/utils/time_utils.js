function formatTimeForOneSignal(scheduleTime) {
    if (!scheduleTime) return null;

    // Parse input time (e.g., "7:00 AM" or "9:00 PM")
    const parts = scheduleTime.trim().split(' ');

    // If it's already in 24h format (HH:mm or HH:mm:ss) and doesn't have AM/PM
    if (parts.length < 2) {
        const timeParts = scheduleTime.split(':');
        if (timeParts.length >= 2) {
            const h = timeParts[0].padStart(2, '0');
            const m = timeParts[1].padStart(2, '0');
            const s = (timeParts[2] || '00').padStart(2, '0');
            return `${h}:${m}:${s}`;
        }
        return scheduleTime;
    }

    const [time, period] = parts;
    let [hours, minutes] = time.split(':').map(Number);

    if (period.toUpperCase() === 'PM' && hours !== 12) hours += 12;
    if (period.toUpperCase() === 'AM' && hours === 12) hours = 0;

    // Return as HH:mm:ss (padded)
    return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:00`;
}

module.exports = { formatTimeForOneSignal };
