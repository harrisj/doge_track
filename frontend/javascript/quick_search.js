import lunr from "lunr";

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

document.addEventListener("DOMContentLoaded", async () => {
    // Application Data States
    let documents = [];
    let docLookup = {};
    let lunrIndex = null;
    let activeIndex = -1; // -1 means focus is strictly on the text input

    const searchInput = document.getElementById("navbar-search");
    const resultsMenu = document.getElementById("search-results-menu");

    // 1. Fetch JSON Data Asynchronously from Endpoint
    async function initialization() {
        try {
            // Replace with your real JSON file endpoint URL path
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
        } catch (error) {
            console.error("Failed initialization process:", error);
        }
    }

    // Execute initialization payload immediately
    await initialization();

    // 2. Input Monitoring Logic
    searchInput.addEventListener("input", (e) => {
        const query = e.target.value.trim();
        activeIndex = -1; // Reset highlight pointer anytime typing shifts context

        if (query.length < 2 || !lunrIndex) {
            clearResults();
            return;
        }

        const matches = lunrIndex.search(`${query}*`);

        // Define your minimum relevance threshold
        const minScore = 1;
        const filteredMatches = matches
            .filter((item) => item.score >= minScore)
            .slice(0, 5);

        renderResults(query, filteredMatches);
    });

    // 3. Clear UI Elements safely
    function clearResults() {
        resultsMenu.innerHTML = "";
        resultsMenu.classList.add("hidden");
        searchInput.setAttribute("aria-expanded", "false");
        activeIndex = -1;
    }

    // 4. Dom Dynamic Generation Template
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

            // We embed anchor paths explicitly inside custom markup definitions
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

    // 5. Intercept Key Navigation Commands
    searchInput.addEventListener("keydown", (e) => {
        // Collect non-disabled item links rendered inside results
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
                // If an item is active via keyboard selection, go to its link
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

    // 6. Manage Active Selection Visual Highlights
    function updateItemVisualFocus(items) {
        items.forEach((item, idx) => {
            const anchor = item.querySelector("a");
            if (idx === activeIndex) {
                // Use daisyUI focus classes explicitly
                anchor.classList.add("bg-base-200", "text-base-content");
                item.setAttribute("aria-selected", "true");
                searchInput.setAttribute("aria-activedescendant", item.id);

                // Scroll the element into view safely if overflow list container gets scrolled past
                item.scrollIntoView({ block: "nearest" });
            } else {
                anchor.classList.remove("bg-base-200");
                item.removeAttribute("aria-selected");
            }
        });
    }

    // 7. Click Dismiss Handling
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
});
