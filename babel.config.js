module.exports = function(api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    plugins: [

      // Remove console.log statements in production
      ['transform-remove-console', { exclude: ['error', 'warn'] }],

      // Optimize imports
      [
        'module-resolver',
        {
          root: ['./src'],
          extensions: ['.ios.js', '.android.js', '.js', '.ts', '.tsx', '.json'],
          alias: {
            '@components': './src/components',
            '@screens': './src/screens',
            '@navigation': './src/navigation',
            '@store': './src/store',
            '@services': './src/services',
            '@utils': './src/utils',
            '@constants': './src/constants',
            '@assets': './src/assets',
            '@hooks': './src/hooks',
            '@localization': './src/localization',
          },
        },
      ],
    ],
    env: {
      production: {
        plugins: [
          'transform-remove-console',
          // Remove all __DEV__ code blocks in production
          ['transform-define', {
            __DEV__: false,
          }],
        ],
      },
    },
  };
};
