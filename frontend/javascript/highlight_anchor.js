import { swup } from "./swup.js";

// 2. Core highlight function using daisyUI colors
function triggerDaisyUIFlash(targetId) {
    const targetDiv = document.getElementById(targetId);
    if (!targetDiv) return;

    // Clear URL address bar immediately
    history.replaceState(
        null,
        null,
        window.location.pathname + window.location.search,
    );

    // Apply instant flash style
    targetDiv.classList.add(
        "bg-warning/20",
        "transition-colors",
        "duration-1000",
        "ease-out",
    );

    // Let go so Tailwind fades it back to bg-base-200 over 2000ms
    setTimeout(() => {
        targetDiv.classList.remove(
            "bg-warning/20",
            "transition-colors",
            "duration-1000",
            "ease-out",
        );
    }, 500);
}

// 3. Logic to extract hash and execute
function checkHashAndHighlight() {
    if (window.location.hash) {
        const targetId = window.location.hash.substring(1);
        triggerDaisyUIFlash(targetId);
    }
}

// Scenario A: Handles the very first direct page load visit
window.addEventListener("DOMContentLoaded", checkHashAndHighlight);

// Scenario B: Hook into swup to run AFTER the page transition finishes animating
// Note: Use 'contentReplaced' for swup v3 or 'page:view' for swup v4
swup.hooks.on("page:view", () => {
    checkHashAndHighlight();
});
