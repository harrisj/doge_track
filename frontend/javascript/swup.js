import Swup from "swup";
import SwupA11yPlugin from "@swup/a11y-plugin";
import SwupScriptsPlugin from "@swup/scripts-plugin";

export const swup = new Swup({
    plugins: [
        new SwupA11yPlugin(),
        new SwupScriptsPlugin({
            // Exclude Font Awesome or global scripts from re-running
            exclude: (script) =>
                script.src.includes("fontawesome") ||
                script.src.includes("search"),
        }),
    ],
    linkToSelf: "navigate",
});

swup.hooks.on("content:replace", () => {
    if (window.FontAwesome && typeof window.FontAwesome.redraw === "function") {
        window.FontAwesome.redraw();
    }
});

swup.hooks.on("visit:start", () => {
    document.getElementById("my-drawer-3").checked = false;
});
