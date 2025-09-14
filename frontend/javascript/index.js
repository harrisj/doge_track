import "bridgetown-quick-search";
import "$styles/index.css";
import "$styles/syntax-highlighting.css";

import * as Turbo from "@hotwired/turbo";

// Uncomment the line below to add transition animations when Turbo navigates.
// We recommend adding <meta name="turbo-cache-control" content="no-preview" />
// to your HTML head if you turn on transitions. Use data-turbo-transition="false"
// on your <main> element for pages where you don't want any transition animation.
//
import "./turbo_transitions.js";

// Import all JavaScript & CSS files from src/_components
import components from "$components/**/*.{js,jsx,js.rb,css}";

// import "@fontsource-variable/readex-pro"
// import "@fontsource-variable/fira-code"

console.info("Bridgetown is loaded!");
