/* Adapted from the Bridgetown quick searvch */
import lunr from "lunr";

class SearchEngine {
  async generateIndex(indexData) {
    this.index = lunr(function () {
      this.ref("id");
      this.field("id");
      this.field("title", { boost: 10 });
      this.field("agency", { boost: 5 });
      this.field("name", { boost: 5 });
      this.field("url");
      this.field("content");

      indexData.forEach((item) => {
        if (item.content) {
          this.add(item);
        }
      });
    });

    this.indexData = indexData;
  }

  performSearch(query, snippetLength = null, displayCollection = false) {
    if (this.index) {
      this.query = query;
      const results = this.index.search(this.query);

      if (results.length) {
        return results.map((result) => {
          const item = this.indexData.find((item) => item.id == result.ref);
          const contentPreview = this.previewTemplate(
            item.content,
            snippetLength,
          );
          const collectionName = displayCollection
            ? `${item.collection.name} > `
            : "";
          const titlePreview =
            collectionName +
            this.previewTemplate(item.title) +
            `<!--(${result.score})-->`;

          return {
            url: item.url.trim(),
            heading: titlePreview,
            preview: contentPreview,
          };
        });
      } else {
        return [];
      }
    } else {
      throw new Error(
        "Search index hasn't yet loaded. Run the generateIndex function",
      );
    }
  }

  previewTemplate(text, length) {
    if (length == null) length = 300;
    const padding = length / 2;
    let output;

    if (length) {
      // Get sorted locations of all the words in the search query
      const textToSearch = text.toLowerCase();
      const wordLocations = this.query
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

    this.query
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
}

export default SearchEngine;
