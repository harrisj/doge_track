import lunr from "lunr";

import { swup } from "./swup.js";

const JSON_URL = "/search-index.json";

function previewTemplate(query, text, length) {
    if (length == null) length = 300;
    const padding = length / 2;
    let output;

    if (length) {
        // Get sorted locations of all the words in the search query
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

        // Grab the first location and back up a bit
        // Then go past second location or just use the length
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

// Separate initialization function
async function initializeSearch() {
    let documents = [];
    let docLookup = {};
    let lunrIndex = null;
    let activeIndex = -1; // -1 means focus is strictly on the text input

    const searchInput = document.getElementById("navbar-search");
    const resultsMenu = document.getElementById("search-results-menu");

    async function initialization() {
        try {
            const response = await fetch(JSON_URL);
            if (!response.ok) throw new Error("Network error pulling file.");

            documents = await response.json();

            // Build internal quick dictionary lookup mapping
            documents.forEach((doc) => {
                docLookup[doc.id] = doc;
            });

            // Build Lunr Search Engine Instance
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
                }, this);
            });

            // Add event listeners for search input
            searchInput.addEventListener("input", (e) => {
                const query = e.target.value.trim();
                activeIndex = -1; // Reset highlight pointer anytime typing shifts context

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
        } catch (error) {
            console.error("Failed initialization process:", error);
        }
    }

    // Execute initialization payload immediately
    await initialization();

    function clearResults() {
        resultsMenu.innerHTML = "";
        resultsMenu.classList.add("hidden");
        searchInput.setAttribute("aria-expanded", "false");
        activeIndex = -1;
    }

    function renderResults(query, results) {
        resultsMenu.innerHTML = "";

        if (results.length === 0) {
            resultsMenu.innerHTML = `<li class="disabled"><span class="text-base-content/80 py-2 px-3">No pages found</span></li>`;
            resultsMenu.classList.remove("hidden");
            searchInput.setAttribute("aria-expanded", "true");
            return;
        }

        results.forEach((result, idx) => {
            const doc = docLookup[result.ref];
            const li = document.createElement("li");
            li.setAttribute("role", "option");
            li.setAttribute("id", `search-item-${idx}`);

            if (doc.type == "Page" || doc.type == "Event") {
                content = previewTemplate(query, doc.content, 120);
            } else {
                content = doc.content;
            }

            li.innerHTML = `
        <a href="${doc.url}" tabindex="-1" class="flex flex-col items-start gap-0.5 py-2 px-3 rounded-md transition-colors duration-150">
          <span class="font-medium text-sm text-base-content title-element">${doc.icon_html} ${doc.title}</span>
          <span class="text-xs text-base-content/80 font-mono url-element">${content}</span>
        </a>
      `;
            resultsMenu.appendChild(li);
        });

        resultsMenu.classList.remove("hidden");
        searchInput.setAttribute("aria-expanded", "true");
    }

    // Intercept Key Navigation Commands
    searchInput.addEventListener("keydown", (e) => {
        const listItems = resultsMenu.querySelectorAll("li:not(.disabled)");
        if (listItems.length === 0) return;

        switch (e.key) {
            case "ArrowDown":
                e.preventDefault();
                activeIndex =
                    activeIndex + 1 >= listItems.length ? 0 : activeIndex + 1;
                updateItemVisualFocus(listItems);
                break;

            case "ArrowUp":
                e.preventDefault();
                activeIndex =
                    activeIndex - 1 < 0
                        ? listItems.length - 1
                        : activeIndex - 1;
                updateItemVisualFocus(listItems);
                break;

            case "Enter":
                if (activeIndex >= 0 && activeIndex < listItems.length) {
                    e.preventDefault();
                    const targetAnchor =
                        listItems[activeIndex].querySelector("a");
                    if (targetAnchor)
                        window.location.href =
                            targetAnchor.getAttribute("href");
                }
                break;

            case "Escape":
                e.preventDefault();
                clearResults();
                searchInput.blur();
                break;
        }
    });

    function updateItemVisualFocus(items) {
        items.forEach((item, idx) => {
            const anchor = item.querySelector("a");
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
    }

    document.addEventListener("click", (e) => {
        if (
            !searchInput.contains(e.target) &&
            !resultsMenu.contains(e.target)
        ) {
            clearResults();
        }
    });

    searchInput.addEventListener("focus", () => {
        if (searchInput.value.trim().length >= 2) {
            resultsMenu.classList.remove("hidden");
            searchInput.setAttribute("aria-expanded", "true");
        }
    });
}

swup.hooks.on("content:replace", () => {
    const searchInput = document.querySelector("#navbar-search");
    const resultsContainer = document.querySelector("#search-results-menu");

    if (searchInput) searchInput.value = "";
    if (resultsContainer) resultsContainer.innerHTML = "";
});

// Attach the initialization function to both DOMContentLoaded and turbolinks:load
document.addEventListener("DOMContentLoaded", initializeSearch);

document.addEventListener("DOMContentLoaded", () => {
    // console.log("DOMContentLoaded event fired");
    initializeSearch();
});

swup.hooks.on("page:view", (visit) => {
    // console.log("Swup page:view fired");
    initializeSearch();
});
