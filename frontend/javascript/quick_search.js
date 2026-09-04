import lunr from "lunr";

import { swup } from "./swup.js";

const JSON_URL = "/search-index.json";

// Module scope state - persists across Swup navigations
let documents = [];
let docLookup = {};
let lunrIndex = null;
let activeIndex = -1;
let searchIndexLoaded = false;

function getIconHtml(cssClass) {
    return `<i class="fa-sharp fa-solid ${cssClass} fa-fw" aria-hidden="true"></i>`;
}

function previewTemplate(query, text, length) {
    if (length == null) length = 300;
    const padding = length / 2;
    let output;

    if (length) {
        const textToSearch = text.toLowerCase();
        const wordLocations = query
            .toLowerCase()
            .split(" ")
            .map((word) => {
                return textToSearch.indexOf(word);
            })
            .filter((location) => location != -1)
            .sort((a, b) => {
                return a - b;
            });

        if (wordLocations[1]) {
            length = Math.min(wordLocations[1] - wordLocations[0], length);
        }

        output = text.substr(
            Math.max(0, wordLocations[0] - padding),
            length + padding,
        );
    } else {
        output = text;
    }

    if (!text.startsWith(output)) {
        output = "…" + output;
    }
    if (!text.endsWith(output)) {
        output = output + "…";
    }

    query
        .toLowerCase()
        .split(" ")
        .forEach((word) => {
            if (word != "") {
                output = output.replace(
                    new RegExp(`(${word.replace(/[\.\*\+\(\)]/g, "")})`, "ig"),
                    `<strong>$1</strong>`,
                );
            }
        });

    return output;
}

/**
 * Loads the search index and builds the Lunr index once.
 */
async function loadSearchData() {
    if (searchIndexLoaded) return;

    try {
        const response = await fetch(JSON_URL);
        if (!response.ok) throw new Error("Network error pulling file.");

        documents = await response.json();

        documents.forEach((doc) => {
            docLookup[doc.id] = doc;
        });

        lunrIndex = lunr(function () {
            this.pipeline.remove(lunr.stemmer);
            this.searchPipeline.remove(lunr.stemmer);

            this.ref("id");
            this.field("id");
            this.field("title", { boost: 20 });
            this.field("alt_title", { boost: 20 });
            this.field("agency", { boost: 5 });
            this.field("name", { boost: 5 });
            this.field("url");
            this.field("content");

            documents.forEach((doc) => {
                this.add(doc);
            });
        });

        searchIndexLoaded = true;
    } catch (error) {
        console.error("Failed to load search index:", error);
        throw error;
    }
}

/**
 * Attaches event listeners to the search elements.
 */
function attachEventListeners(searchInput, resultsMenu) {
    // Prevent duplicate listeners if element is persisted via Swup
    if (searchInput._searchListenersAttached) return;

    const clearResults = () => {
        resultsMenu.innerHTML = "";
        resultsMenu.classList.add("hidden");
        searchInput.setAttribute("aria-expanded", "false");
        activeIndex = -1;
    };

    const renderResults = (query, results) => {
        resultsMenu.innerHTML = "";

        if (results.length === 0) {
            resultsMenu.innerHTML = `<li class="disabled"><span class="text-base-content/80 py-2 px-3">No pages found</span></li>`;
            resultsMenu.classList.remove("hidden");
            searchInput.setAttribute("aria-expanded", "true");
            return;
        }

        results.forEach((result, idx) => {
            const doc = docLookup[result.ref];
            if (!doc) return;

            const li = document.createElement("li");
            li.setAttribute("role", "option");
            li.setAttribute("id", `search-item-${idx}`);

            let content = "";
            if (doc.type === "Page" || doc.type === "Event") {
                content = previewTemplate(query, doc.content, 120);
            } else {
                content = doc.content;
            }

            li.innerHTML = `
                <a href="${doc.url}" tabindex="-1" class="flex flex-col items-start gap-0.5 py-2 px-3 rounded-md transition-colors duration-150">
                  <span class="font-medium text-sm text-base-content title-element"><i class="fa-sharp fa-solid ${doc.ic || ''} fa-fw" aria-hidden="true"></i> ${doc.title}</span>
                  <span class="text-xs text-base-content/80 font-mono url-element">${content}</span>
                </a>
            `;
            resultsMenu.appendChild(li);
        });

        resultsMenu.classList.remove("hidden");
        resultsMenu.setAttribute("aria-expanded", "true");
    };

    const updateItemVisualFocus = (items) => {
        items.forEach((item, idx) => {
            const anchor = item.querySelector("a");
            if (!anchor) return;

            if (idx === activeIndex) {
                anchor.classList.add("bg-base-200", "text-base-content");
                item.setAttribute("aria-selected", "true");
                searchInput.setAttribute("aria-activedescendant", item.id);
                item.scrollIntoView({ block: "nearest" });
            } else {
                anchor.classList.remove("bg-base-200");
                item.removeAttribute("aria-selected");
            }
        });
    };

    searchInput.addEventListener("input", (e) => {
        const query = e.target.value.trim();
        activeIndex = -1;

        if (query.length < 2 || !lunrIndex) {
            clearResults();
            return;
        }

        const matches = lunrIndex.search(`${query}*`);
        const minScore = 1;
        const filteredMatches = matches
            .filter((item) => item.score >= minScore)
            .slice(0, 5);

        renderResults(query, filteredMatches);
    });

    searchInput.addEventListener("keydown", (e) => {
        const listItems = resultsMenu.querySelectorAll("li:not(.disabled)");
        if (listItems.length === 0) return;

        switch (e.key) {
            case "ArrowDown":
                e.preventDefault();
                activeIndex = activeIndex + 1 >= listItems.length ? 0 : activeIndex + 1;
                updateItemVisualFocus(listItems);
                break;
            case "ArrowUp":
                e.preventDefault();
                activeIndex = activeIndex - 1 < 0 ? listItems.length - 1 : activeIndex - 1;
                updateItemVisualFocus(listItems);
                break;
            case "Enter":
                if (activeIndex >= 0 && activeIndex < listItems.length) {
                    e.preventDefault();
                    const targetAnchor = listItems[activeIndex].querySelector("a");
                    if (targetAnchor) window.location.href = targetAnchor.getAttribute("href");
                }
                break;
            case "Escape":
                e.preventDefault();
                clearResults();
                searchInput.blur();
                break;
        }
    });

    searchInput.addEventListener("focus", () => {
        if (searchInput.value.trim().length >= 2) {
            resultsMenu.classList.remove("hidden");
            searchInput.setAttribute("aria-expanded", "true");
        }
    });

    document.addEventListener("click", (e) => {
        if (!searchInput.contains(e.target) && !resultsMenu.contains(e.target)) {
            clearResults();
        }
    });

    // Mark as attached to prevent duplicate listeners on persisted elements
    searchInput._searchListenersAttached = true;
}

/**
 * Main initialization function that can be called multiple times (on load and after Swup navigation).
 */
async function initSearch() {
    try {
        await loadSearchData();

        const searchInput = document.getElementById("navbar-search");
        const resultsMenu = document.getElementById("search-results-menu");

        if (searchInput && resultsMenu) {
            attachEventListeners(searchInput, resultsMenu);
        }
    } catch (err) {
        console.error("Search initialization failed:", err);
    }
}

// Initial load
document.addEventListener("DOMContentLoaded", initSearch);

// Swup: Reset UI on content replacement and re-init listeners for new DOM if necessary
swup.hooks.on("content:replace", () => {
    const searchInput = document.querySelector("#navbar-search");
    const resultsContainer = document.querySelector("#search-results-menu");

    if (searchInput) searchInput.value = "";
    if (resultsContainer) resultsContainer.innerHTML = "";

    // Re-init to catch new elements if the navbar was swapped, 
    // or re-attach listeners if they were part of a non-persisted container.
    initSearch();
});
