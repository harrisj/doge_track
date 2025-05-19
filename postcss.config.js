module.exports = {
  plugins: {
    'tailwindcss': {}, // ← This line, helps trigger automatic rebuilds
    'postcss-flexbugs-fixes': {},
    'postcss-preset-env': {
      autoprefixer: {
        flexbox: 'no-2009'
      },
      stage: 2
    }
  }
}
