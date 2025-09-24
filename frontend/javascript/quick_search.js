/* Use in your app by simply adding to your app's index.js:

import "bridgetown-quick-search"
*/
import { LitElement, css, html } from "lit";
import { unsafeHTML } from "lit/directives/unsafe-html.js";
import SearchEngine from "./search_engine";

export class BridgetownSearchForm extends LitElement {
  static {
    customElements.define("bridgetown-search-form", this);
  }

  render() {
    return html`<form><slot name="input"></slot></form>
      <slot></slot>`;
  }

  firstUpdated() {
    this.querySelector("input").addEventListener(
      "input",
      this.handleChange.bind(this),
    );
  }

  handleChange(e) {
    const target = e.currentTarget;
    clearTimeout(this.debounce);

    this.debounce = setTimeout(() => {
      this.querySelector("bridgetown-search-results").showResultsForQuery(
        target.value,
      );
    }, 250);
  }
}

export class BridgetownSearchResults extends LitElement {
  static properties = {
    theme: { type: String },
    results: { type: Array },
    snippetLength: { type: Number },
    displayCollection: { type: Boolean },
  };

  static styles = css`
    :host {
      display: block;
      position: absolute;
      margin: 0;
      margin-top: 1px;
      padding: 0;
      width: 94vw;
      max-width: 550px;
      font-weight: 400;
      font-size: 1rem;
      font-style: normal;
      text-transform: initial;
      z-index: 9999;
      background: transparent;
    }
    [part="inner"] {
      margin: 0;
      list-style-type: none;
      padding: 0.8em 1.2em;
      background: var(--background, #ffffff);
      color: var(--text-color, #333333);
      display: none;
      border-radius: var(--border-radius, 10px);
      border-top-left-radius: var(--border-corner-radius, 4px);
      max-height: 50vh;
      overflow: auto;
      overflow-x: hidden;
      box-shadow: 0px 15px 15px rgba(0, 0, 0, 0.1);
    }
    [part="inner"].show {
      display: block;
    }
    [part="inner"].dark-theme {
      background: var(--background-dark, #222222);
      color: var(--text-color-dark, #dddddd);
    }

    ul > a {
      margin-top: 1.5em;
      margin-bottom: 0;
    }
    ul > a:first-of-type {
      margin-top: 0;
    }
    li {
      margin: 0;
      padding: 0;
    }

    h1 {
      font-size: 1em;
      font-weight: 400;
      font-style: normal;
      margin-top: 0;
      margin-bottom: 0.5em;
      padding-bottom: 3px;
      border-bottom: 1px solid var(--divider-color, #cccccc);
      color: var(--link-color, #000000);
    }
    h1 a {
      display: block;
    }
    [part="inner"].dark-theme h1 {
      color: var(--link-color-dark, #ffffff);
      border-bottom: 1px solid var(--divider-color-dark, #444444);
    }
    a {
      color: inherit;
      text-decoration: none;
      display: block;
    }
    p {
      margin-top: 0;
      margin-bottom: 1em;
      word-wrap: break-word;
    }
    li p {
      font-size: 0.8em;
    }
    p strong {
      color: var(--link-color, #000000);
    }
    [part="inner"].dark-theme p strong {
      color: var(--link-color-dark, #ffffff);
    }
    p#no-results {
      margin-top: 0.5em;
    }
  `;

  static {
    customElements.define("bridgetown-search-results", this);
  }

  constructor() {
    super();
    this.results = [];
    this.snippetLength = 142;
    this.displayCollection = false;
  }

  connectedCallback() {
    super.connectedCallback();
    this.fetchSearchIndex();

    window.addEventListener("resize", () => {
      window.requestAnimationFrame(this.repositionIfNecessary.bind(this));
      //      clearTimeout(this.resizeDebounce)
      //      this.resizeDebounce = setTimeout(() => {
      //        this.repositionIfNecessary()
      //      }, 100)
    });
  }

  async fetchSearchIndex() {
    const response = await fetch(`/search-index.json`);
    this.searchIndex = await response.json();

    this.searchEngine = new SearchEngine();
    this.searchEngine.generateIndex(this.searchIndex);
  }

  showResultsForQuery(query) {
    this.latestQuery = query;
    if (query && query.length > 1) {
      this.showResults = true;
      this.results = this.searchEngine
        .performSearch(query, this.snippetLength, this.displayCollection)
        .slice(0, 10);
    } else {
      this.showResults = false;
    }
    this.requestUpdate();
  }

  render() {
    this.repositionIfNecessary();

    let resultsStatus = "";
    if (this.results.length == 0) {
      resultsStatus = html`<p id="no-results">
        No results found for "<strong>${this.latestQuery}</strong>"
      </p>`;
    }

    const theme = this.theme == "dark" ? "dark" : "light";

    return html`<ul
      part="inner"
      class="${theme}-theme ${this.showResults ? "show" : ""}"
    >
      ${resultsStatus}
      ${this.results.map((result) => {
        return html`
          <a part="inner-link" href="${result.url}">
            <li>
              <h1>${unsafeHTML(result.heading)}</h1>
              <p>${unsafeHTML(result.preview)}</p>
            </li>
          </a>
        `;
      })}
    </ul>`;
  }

  repositionIfNecessary() {
    this.style.transform = `translateX(0px)`;

    const rect = this.getBoundingClientRect();
    const fullWidth = window.innerWidth - rect.width;
    const offsetWidth = fullWidth - rect.x;

    if (rect.x + rect.width > window.innerWidth) {
      this.style.transform = `translateX(${offsetWidth}px)`;
    }
  }
}
