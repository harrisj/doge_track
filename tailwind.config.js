const defaultTheme = require("tailwindcss/defaultTheme")

/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './src/**/*.{html,md,liquid,erb,serb,rb}',
    './output/**/*.{html,md,liquid,erb,serb,rb}',
    './frontend/javascript/**/*.js',
  ],
  plugins: [
    require("@tailwindcss/typography"),
  ],
  theme: {
    container: {
      center: true,
      padding: '3rem',
    },
  },
}